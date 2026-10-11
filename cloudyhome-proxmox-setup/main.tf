data "proxmox_virtual_environment_nodes" "this" {}

resource "proxmox_virtual_environment_time" "this" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.this.names)
  node_name = each.value
  time_zone = var.timezone
}
