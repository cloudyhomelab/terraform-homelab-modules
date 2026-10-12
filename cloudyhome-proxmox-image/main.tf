data "proxmox_virtual_environment_nodes" "this" {}

resource "proxmox_download_file" "this" {
  for_each = toset(data.proxmox_virtual_environment_nodes.this.names)

  node_name               = each.value
  content_type            = var.config.content_type
  datastore_id            = var.config.datastore_id
  file_name               = var.config.save_file_name
  url                     = var.config.download_url
  checksum                = var.config.checksum
  checksum_algorithm      = var.config.checksum_algorithm
  decompression_algorithm = var.config.decompression_algorithm
  overwrite               = var.config.overwrite
}
