variable "config" {
  description = "Host whose address is registered in NetBox."
  type = object({
    network          = string
    dns_name         = string
    ip4_address_cidr = optional(string)
  })
  nullable = false

  validation {
    condition     = trimspace(var.config.network) != ""
    error_message = "config.network must name a VLAN in NetBox."
  }

  validation {
    condition     = trimspace(var.config.dns_name) != ""
    error_message = "config.dns_name must be the host's FQDN."
  }

  validation {
    # cidrnetmask accepts IPv4 only, unlike cidrhost
    condition     = var.config.ip4_address_cidr == null || can(cidrnetmask(var.config.ip4_address_cidr))
    error_message = "config.ip4_address_cidr must be an IPv4 address with prefix length, e.g. 192.0.2.10/24."
  }
}
