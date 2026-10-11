output "zone_ids" {
  description = "IDs of the created VLAN zones."
  value       = [for zone in proxmox_sdn_zone_vlan.this : zone.id]
}

output "vnet_ids" {
  description = "VNet IDs, keyed by themselves, for use as a VM network device bridge."
  value       = { for vnet in proxmox_sdn_vnet.this : vnet.id => vnet.id }

  # A VM attached to a VNet must wait until the SDN config is applied on the nodes.
  depends_on = [proxmox_sdn_applier.this]
}
