data "proxmox_virtual_environment_nodes" "this" {}

resource "proxmox_virtual_environment_time" "this" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.this.names)
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
