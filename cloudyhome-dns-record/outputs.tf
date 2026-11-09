output "fqdn" {
  description = "Fully qualified domain name of the A record, with trailing dot."
  value       = local.fqdn
}

output "ptr_fqdn" {
  description = "Fully qualified name of the PTR record, with trailing dot."
  value       = local.ptr_fqdn
}
