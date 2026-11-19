output "allow_fqdns" {
  description = "Fully qualified names of the allow records, with trailing dot."
  value       = sort([for n in var.config.allow : "${n}.${local.allow_zone}"])
}

output "deny_fqdns" {
  description = "Fully qualified names of the deny records, including wildcards, with trailing dot."
  value       = sort([for n in local.deny_names : "${n}.${local.deny_zone}"])
}
