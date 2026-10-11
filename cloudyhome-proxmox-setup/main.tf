data "proxmox_virtual_environment_nodes" "this" {}

locals {
  nodes = toset(data.proxmox_virtual_environment_nodes.this.names)

  apt_repositories = jsondecode(file("${path.module}/apt-repositories.json"))

  node_apt_repositories = {
    for pair in setproduct(local.nodes, keys(local.apt_repositories)) :
    "${pair[0]}/${pair[1]}" => {
      node    = pair[0]
      handle  = pair[1]
      enabled = local.apt_repositories[pair[1]]
    }
  }
}

resource "proxmox_virtual_environment_time" "this" {
  for_each  = local.nodes
  node_name = each.value
  time_zone = var.timezone
}

resource "proxmox_virtual_environment_storage_directory" "this" {
  id   = "local"
  path = "/var/lib/vz"

  content = ["backup", "iso", "snippets", "vztmpl"]
  shared  = false
  disable = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "proxmox_virtual_environment_storage_lvmthin" "this" {
  id           = "local-lvm"
  thin_pool    = "data"
  volume_group = "pve"

  content = ["rootdir", "images"]
  disable = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "proxmox_apt_standard_repository" "this" {
  for_each = local.node_apt_repositories
  node     = each.value.node
  handle   = each.value.handle
}

resource "proxmox_apt_repository" "this" {
  for_each  = local.node_apt_repositories
  node      = proxmox_apt_standard_repository.this[each.key].node
  file_path = proxmox_apt_standard_repository.this[each.key].file_path
  index     = proxmox_apt_standard_repository.this[each.key].index
  enabled   = each.value.enabled
}
