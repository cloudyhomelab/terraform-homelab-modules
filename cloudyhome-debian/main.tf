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

  # The guest agent may not have reported an address yet; null instead of failing the apply.
  agent_ipv4 = try(
    flatten([
      for idx, name in proxmox_virtual_environment_vm.this.network_interface_names :
      proxmox_virtual_environment_vm.this.ipv4_addresses[idx] if startswith(name, "en")
    ])[0],
    null
  )
  vm_ip = var.config.dhcp ? local.agent_ipv4 : try(split("/", var.config.ip4_address_cidr)[0], null)
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
      age_secret           = var.age_secret
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

data "proxmox_file" "this" {
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
    timeout = var.config.guest_agent_timeout

    wait_for_ip {
      ipv4 = true
    }
  }

  keyboard_layout = var.config.keyboard_layout
  on_boot         = true
  stop_on_destroy = true

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
    file_id      = data.proxmox_file.this.id
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

  lifecycle {
    precondition {
      condition     = local.vm_ip != null
      error_message = "No IPv4 address reported by the guest agent for ${var.config.name}; cannot create the DNS record."
    }
  }
}
