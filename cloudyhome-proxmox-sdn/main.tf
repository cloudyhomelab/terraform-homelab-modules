locals {
  vnets = merge([
    for zone_id, vnets in var.zones : {
      for vnet_id, tag in vnets :
      "${zone_id}-${vnet_id}" => { id = vnet_id, zone = zone_id, tag = tag }
    }
  ]...)
}

# Destroyed after the zones and VNets, so their removal is applied too.
resource "proxmox_sdn_applier" "finalizer" {}

resource "proxmox_sdn_zone_vlan" "this" {
  for_each = var.zones

  id     = each.key
  bridge = var.bridge
  ipam   = var.ipam

  depends_on = [proxmox_sdn_applier.finalizer]
}

resource "proxmox_sdn_vnet" "this" {
  for_each = local.vnets

  id         = each.value.id
  zone       = proxmox_sdn_zone_vlan.this[each.value.zone].id
  tag        = each.value.tag
  vlan_aware = true

  depends_on = [proxmox_sdn_applier.finalizer]
}

resource "proxmox_sdn_applier" "this" {
  depends_on = [
    proxmox_sdn_zone_vlan.this,
    proxmox_sdn_vnet.this,
  ]

  lifecycle {
    replace_triggered_by = [
      proxmox_sdn_zone_vlan.this,
      proxmox_sdn_vnet.this,
    ]
  }
}
