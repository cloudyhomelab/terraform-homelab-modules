variable "config" {
  type = object({
    node                = string
    vmid                = optional(number, null)
    name                = string
    description         = optional(string, "")
    dhcp                = bool
    searchdomain        = string
    bridge              = string
    ip4_address_cidr    = optional(string)
    dns_addresses       = optional(list(string), [])
    gateway             = optional(string)
    bios                = optional(string, "seabios")
    cores               = optional(number, 1)
    cpu                 = optional(string, "x86-64-v2-AES")
    memory              = optional(number, 2048)
    disk_size           = optional(number, 10)
    timezone            = string
    keyboard_layout     = optional(string, "en-us")
    username            = string
    user_id             = number
    tags                = optional(set(string), [])
    create_dns_record   = optional(bool, true)
    guest_agent_timeout = optional(string, "15m")
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

  validation {
    condition     = trimspace(var.config.bridge) != ""
    error_message = "config.bridge must name an existing bridge or SDN VNet."
  }

  validation {
    condition     = trimspace(var.config.searchdomain) != ""
    error_message = "config.searchdomain must name a DNS domain."
  }
}

variable "user_cloud_init_file" {
  description = "Optional path to user cloud-init template file"
  type        = string
  default     = null

  validation {
    condition = (
      var.user_cloud_init_file == null ||
      try(
        fileexists(var.user_cloud_init_file)
        && (
          endswith(var.user_cloud_init_file, ".yml")
          || endswith(var.user_cloud_init_file, ".yaml")
        ),
        false
      )
    )
    error_message = "user_cloud_init_file must be a .yml or .yaml file and must exist if provided."
  }
}

variable "network_cloud_init_file" {
  description = "Optional path to network cloud-init template file"
  type        = string
  default     = null

  validation {
    condition = (
      var.network_cloud_init_file == null ||
      try(
        fileexists(var.network_cloud_init_file)
        && (
          endswith(var.network_cloud_init_file, ".yml")
          || endswith(var.network_cloud_init_file, ".yaml")
        ),
        false
      )
    )
    error_message = "network_cloud_init_file must be a .yml or .yaml file and must exist if provided."
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

variable "age_secret" {
  type      = string
  sensitive = true
  nullable  = false

  validation {
    condition     = trimspace(var.age_secret) != ""
    error_message = "age_secret must not be empty."
  }
}

variable "image" {
  description = "Disk image on a storage of config.node that the VM disk is created from."
  type = object({
    file_name    = string
    content_type = optional(string, "import")
    datastore_id = optional(string, "local")
  })

  validation {
    condition     = trimspace(var.image.file_name) != ""
    error_message = "image.file_name must name the disk image file."
  }

  validation {
    condition     = contains(["iso", "import"], var.image.content_type)
    error_message = "image.content_type must be iso or import."
  }

  validation {
    condition     = trimspace(var.image.datastore_id) != ""
    error_message = "image.datastore_id must name an existing storage, e.g. local."
  }
}
