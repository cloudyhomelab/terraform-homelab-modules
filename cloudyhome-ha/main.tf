locals {
  datastore_id = "local-lvm"

  fqdn = "${var.config.name}.${var.config.searchdomain}"
  tags = toset(
    concat(
      ["home_assistant"],
      tolist(try(var.config.tags, []))
    )
  )

  # The guest agent may not have reported an address yet; null instead of failing the apply.
  vm_ip = try(
    flatten([
      for idx, name in proxmox_virtual_environment_vm.this.network_interface_names :
      proxmox_virtual_environment_vm.this.ipv4_addresses[idx] if startswith(name, "en")
    ])[0],
    null
  )
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

  # Home Assistant OS images boot only via UEFI.
  bios = "ovmf"

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

  efi_disk {
    datastore_id = local.datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = local.datastore_id
    file_id      = data.proxmox_file.this.id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = var.config.disk_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
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
