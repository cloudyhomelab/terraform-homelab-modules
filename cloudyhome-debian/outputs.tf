output "vm_ipv4_address" {
  description = "Static address, or the DHCP address reported by the guest agent (null until reported)."
  value       = local.vm_ip
}

output "vm_ipv4_addresses" {
  description = "IPv4 addresses per en* interface as reported by the guest agent."
  value = {
    for idx, name in proxmox_virtual_environment_vm.this.network_interface_names :
    name => flatten(proxmox_virtual_environment_vm.this.ipv4_addresses[idx])
    if startswith(name, "en")
  }
}

output "vm_id" {
  description = "Proxmox VM ID, including one assigned by Proxmox when config.vmid is null."
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "fqdn" {
  description = "Fully qualified domain name: config.name in config.searchdomain."
  value       = local.fqdn
}
