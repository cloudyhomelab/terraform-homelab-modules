locals {

  user_cloud_init_path = (
    var.user_cloud_init_file != null ? var.user_cloud_init_file : "${path.module}/user-cloud-init-config.yml"
  )

  network_cloud_init_path = (
    var.network_cloud_init_file != null ? var.network_cloud_init_file :
    (
      var.config.dhcp ?
      "${path.module}/network-dhcp-cloud-init-config.yml" :
      "${path.module}/network-static-cloud-init-config.yml"
    )
  )

  fqdn = "${var.config.name}.${var.config.searchdomain}"
  tags = toset(
    concat(
      ["packer-debian"],
      tolist(try(var.config.tags, []))
    )
  )

  en_if  = one([for n in proxmox_virtual_environment_vm.this.network_interface_names : n if startswith(n, "en")])
  en_idx = index(proxmox_virtual_environment_vm.this.network_interface_names, local.en_if)
  vm_ip  = flatten(proxmox_virtual_environment_vm.this.ipv4_addresses[local.en_idx])[0]
}

data "keycloak_realm" "this" {
  realm = var.ca_keycloak_realm
}

resource "keycloak_openid_client" "this" {
  realm_id                 = data.keycloak_realm.this.id
  client_id                = local.fqdn
  name                     = local.fqdn
  enabled                  = true
  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.config.node

  source_raw {
    data = templatefile(local.user_cloud_init_path, {
      config               = var.config,
      tags                 = local.tags,
      fqdn                 = local.fqdn
      ca_server_url        = var.ca_keycloak_server_url
      ca_sso_client_id     = keycloak_openid_client.this.client_id
      ca_sso_client_secret = keycloak_openid_client.this.client_secret
      ca_sso_token_url     = var.ca_keycloak_token_url
      ca_user_public_key   = trimspace(var.ca_user_public_key)
    })
    file_name = "${var.config.name}-user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "network_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.config.node

  source_raw {
    data = templatefile(local.network_cloud_init_path, {
      config = var.config,
    })
    file_name = "${var.config.name}-network-data-cloud-config.yaml"
  }
}

data "proxmox_virtual_environment_file" "this" {
  node_name    = var.config.node
  datastore_id = "local"
  content_type = "iso"
  file_name    = var.image_name
}

resource "proxmox_virtual_environment_vm" "this" {
  node_name = var.config.node

  vm_id       = var.config.vmid
  name        = var.config.name
  description = var.config.description
  tags        = local.tags

  bios = var.config.bios

  agent {
    enabled = true
  }

  keyboard_layout = var.config.keyboard_layout
  on_boot         = true

  operating_system {
    type = "l26"
  }

  cpu {
    cores = var.config.cores
    type  = var.config.cpu
  }

  memory {
    dedicated = var.config.memory
    floating  = var.config.memory
  }

  serial_device {
    device = "socket"
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = "local-lvm"
    file_id      = data.proxmox_virtual_environment_file.this.id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = var.config.disk_size
  }

  initialization {
    user_data_file_id    = proxmox_virtual_environment_file.user_data_cloud_config.id
    network_data_file_id = proxmox_virtual_environment_file.network_cloud_config.id
  }

  network_device {
    bridge = var.config.bridge
  }

  smbios {
    serial = "ds=nocloud-net;h=${var.config.name}"
  }
}


resource "dns_a_record_set" "this" {
  count     = var.config.create_dns_record ? 1 : 0
  zone      = "${var.config.searchdomain}."
  name      = var.config.name
  addresses = [local.vm_ip]
  ttl       = 300
}

output "vm_ipv4_address" {
  value = {
    for idx, name in proxmox_virtual_environment_vm.this.network_interface_names :
    name => flatten(proxmox_virtual_environment_vm.this.ipv4_addresses[idx])
    if startswith(name, "en")
  }
}
