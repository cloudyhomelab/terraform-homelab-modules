variable "config" {
  type = object({
    node              = string
    vmid              = optional(number, null)
    name              = string
    description       = optional(string, "")
    dhcp              = bool
    searchdomain      = optional(string, "localdomain")
    bridge            = optional(string, "LabNet")
    ip4_address_cidr  = optional(string)
    dns_addresses     = optional(set(string), [])
    gateway           = optional(string)
    bios              = optional(string, "seabios")
    cores             = optional(number, 1)
    cpu               = optional(string, "x86-64-v2-AES")
    memory            = optional(number, 2048)
    disk_size         = optional(number, 10)
    timezone          = string
    keyboard_layout   = optional(string, "en-us")
    username          = string
    user_id           = number
    tags              = optional(set(string), [])
    create_dns_record = optional(bool, true)
    age_secret        = optional(string, "")
  })

  validation {
    condition     = var.config.dhcp || (!var.config.dhcp && var.config.ip4_address_cidr != null)
    error_message = "If DHCP is false, then ip4 address is required"
  }

  validation {
    condition     = var.config.dhcp || (!var.config.dhcp && var.config.gateway != null)
    error_message = "If DHCP is false, then gateway is required"
  }

  validation {
    condition     = var.config.dhcp || (!var.config.dhcp && length(var.config.dns_addresses) >= 1)
    error_message = "If DHCP is false, then DNS is required"
  }

  validation {
    condition     = var.config.dhcp || (!var.config.dhcp && length(var.config.dns_addresses) <= 2)
    error_message = "Too many DNS addresses specified, max 2 is allowed"
  }

  validation {
    condition     = var.config.dhcp || can(cidrhost(var.config.ip4_address_cidr, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "user_cloud_init_file" {
  description = "Optional path to user cloud-init template file"
  type        = string
  default     = null

  validation {
    condition = (
      var.user_cloud_init_file == null ||
      can(
        fileexists(var.user_cloud_init_file)
        && (
          endswith(var.user_cloud_init_file, ".yml")
          || endswith(var.user_cloud_init_file, ".yaml")
        )
      )
    )
    error_message = "user_cloug_init_file must be a .yml or .yaml file and must exist if provided."
  }
}

variable "network_cloud_init_file" {
  description = "Optional path to user cloud-init template file"
  type        = string
  default     = null

  validation {
    condition = (
      var.network_cloud_init_file == null ||
      can(
        fileexists(var.network_cloud_init_file)
        && (
          endswith(var.network_cloud_init_file, ".yml")
          || endswith(var.network_cloud_init_file, ".yaml")
        )
      )
    )
    error_message = "user_cloug_init_file must be a .yml or .yaml file and must exist if provided."
  }
}

variable "ca_keycloak_realm" {
  type      = string
  sensitive = true
}

variable "ca_keycloak_server_url" {
  type      = string
  sensitive = true
}

variable "ca_keycloak_token_url" {
  type      = string
  sensitive = true
}

variable "ca_user_public_key" {
  type      = string
  sensitive = true
}

variable "image_name" {
  type = string
}
