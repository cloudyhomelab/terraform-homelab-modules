variable "config" {
  description = "RPZ zones and the names written to them."
  type = object({
    allow_zone = string
    deny_zone  = string
    allow      = optional(set(string), [])
    deny       = optional(set(string), [])
    ttl        = optional(number, 300)
  })

  validation {
    condition     = trimspace(var.config.allow_zone) != "" && trimspace(var.config.deny_zone) != ""
    error_message = "config.allow_zone and config.deny_zone must name DNS zones."
  }

  validation {
    condition     = trimsuffix(var.config.allow_zone, ".") != trimsuffix(var.config.deny_zone, ".")
    error_message = "config.allow_zone and config.deny_zone must be different zones."
  }

  validation {
    condition = alltrue([
      for n in var.config.allow :
      can(regex("^(\\*\\.)?([a-z0-9_]([a-z0-9_-]*[a-z0-9_])?\\.)*[a-z0-9_]([a-z0-9_-]*[a-z0-9_])?$", n))
    ])
    error_message = "config.allow entries must be lowercase domain names without trailing dot, optionally starting with \"*.\"."
  }

  validation {
    condition = alltrue([
      for n in var.config.deny :
      can(regex("^([a-z0-9_]([a-z0-9_-]*[a-z0-9_])?\\.)*[a-z0-9_]([a-z0-9_-]*[a-z0-9_])?$", n))
    ])
    error_message = "config.deny entries must be lowercase domain names without trailing dot or \"*.\" prefix; subdomains are blocked automatically."
  }

  validation {
    condition = length(setintersection(
      var.config.allow,
      toset(flatten([for d in var.config.deny : [d, "*.${d}"]])),
    )) == 0
    error_message = "config.allow and config.deny write the same record name to both zones: ${join(", ", sort(setintersection(var.config.allow, toset(flatten([for d in var.config.deny : [d, "*.${d}"]])))))}."
  }
}
