variable "config" {
  description = "VM settings. The VM always takes its address from DHCP."
  type = object({
    node                = string
    vmid                = optional(number, null)
    name                = string
    description         = optional(string, "")
    searchdomain        = string
    bridge              = string
    cores               = optional(number, 1)
    cpu                 = optional(string, "x86-64-v2-AES")
    memory              = optional(number, 2048)
    disk_size           = optional(number, 32)
    keyboard_layout     = optional(string, "en-us")
    tags                = optional(set(string), [])
    create_dns_record   = optional(bool, true)
    reverse_zone        = optional(string)
    guest_agent_timeout = optional(string, "15m")
  })

  validation {
    condition     = trimspace(var.config.bridge) != ""
    error_message = "config.bridge must name an existing bridge or SDN VNet."
  }

  validation {
    condition     = trimspace(var.config.searchdomain) != ""
    error_message = "config.searchdomain must name a DNS domain."
  }

  validation {
    condition     = !var.config.create_dns_record || var.config.reverse_zone != null
    error_message = "config.reverse_zone is required when create_dns_record is true."
  }
}

variable "image_name" {
  description = "Disk image file name on the node's `local` storage (content type `iso`)."
  type        = string
}
