variable "timezone" {
  description = "IANA time zone set on every node in the cluster, e.g. Europe/Helsinki."
  type        = string
}

variable "pve_search_domain" {
  description = "Domain for the PVE nodes."
  type        = string
  nullable    = false
}

variable "acme_dns" {
  type = object({
    plugin           = string
    api              = string
    validation_delay = optional(number, 120)
    data             = map(string)
  })

  sensitive = true
}
