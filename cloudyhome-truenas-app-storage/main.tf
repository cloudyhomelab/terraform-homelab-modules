locals {
  entries = flatten([
    for key, client in var.clients : [
      for entry in client.storage : {
        pair       = "${entry.app}/${entry.dataset}"
        app        = entry.app
        dataset    = entry.dataset
        recordsize = entry.recordsize
        client     = key
        address    = client.address
      }
    ]
  ])

  by_pair = { for entry in local.entries : entry.pair => entry... }

  # Keyed by pair, never by client, so renaming a client moves no dataset or share
  exports = {
    for pair, entries in local.by_pair : pair => {
      app         = entries[0].app
      dataset     = entries[0].dataset
      recordsizes = distinct([for entry in entries : coalesce(entry.recordsize, "inherit")])
      hosts       = sort(distinct([for entry in entries : entry.address if entry.address != null]))
      clients     = sort(distinct([for entry in entries : entry.client]))
      addressed   = sort(distinct([for entry in entries : entry.client if entry.address != null]))
    }
  }

  # TrueNAS reads an empty host list as every host, so a dataset without an addressed client gets no share at all
  shared = { for pair, export in local.exports : pair => export if length(export.hosts) > 0 }
}

resource "truenas_dataset" "app" {
  for_each = toset([for export in values(local.exports) : export.app])

  name = "${var.root}/${each.key}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "data" {
  for_each = local.exports

  name       = "${truenas_dataset.app[each.value.app].name}/${each.value.dataset}"
  recordsize = each.value.recordsizes[0] == "inherit" ? null : each.value.recordsizes[0]

  lifecycle {
    prevent_destroy = true

    # Clients sharing a dataset must agree on its properties, or each apply would flip them
    precondition {
      condition     = length(each.value.recordsizes) == 1
      error_message = "${each.key}: clients ${join(", ", each.value.clients)} want different recordsize (${join(", ", each.value.recordsizes)})."
    }
  }
}

resource "truenas_nfs_share" "data" {
  for_each = local.shared

  path          = truenas_dataset.data[each.key].mountpoint
  comment       = join(", ", each.value.addressed)
  hosts         = each.value.hosts
  networks      = []
  maproot_user  = "root"
  maproot_group = "root"
}
