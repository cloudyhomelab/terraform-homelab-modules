output "user_token" {
  description = "Full API token, as user@realm!token=secret, for the provider's api_token argument."
  value       = proxmox_virtual_environment_user_token.this.value
  sensitive   = true
}

output "token_id" {
  description = "Token ID, as user@realm!token."
  value       = "${proxmox_virtual_environment_user.this.user_id}!${proxmox_virtual_environment_user_token.this.token_name}"
}

output "user_id" {
  description = "Created Proxmox user."
  value       = proxmox_virtual_environment_user.this.user_id
}

output "role_id" {
  description = "Created Proxmox role."
  value       = proxmox_virtual_environment_role.this.role_id
}
