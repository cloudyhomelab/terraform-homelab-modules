variable "config" {
  description = "Host whose A and PTR records are managed."
  type = object({
    name         = string
    zone         = string
    ipv4         = string
    reverse_zone = string
    ttl          = optional(number, 300)
  })

  validation {
    condition     = trimspace(var.config.name) != ""
    error_message = "config.name must name the host, relative to config.zone."
  }

  validation {
    condition     = trimspace(var.config.zone) != ""
    error_message = "config.zone must name a DNS zone."
  }

  validation {
    condition     = var.config.ipv4 == null || can(cidrhost("${var.config.ipv4}/32", 0))
    error_message = "config.ipv4 must be an IPv4 address without prefix length."
  }

  validation {
    condition     = endswith(trimsuffix(var.config.reverse_zone, "."), ".in-addr.arpa")
    error_message = "config.reverse_zone must be an in-addr.arpa zone, e.g. 2.0.192.in-addr.arpa."
  }
}
