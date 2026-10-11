variable "zones" {
  description = "VLAN zones keyed by zone ID, each mapping VNet ID to VLAN tag."
  type        = map(map(number))

  validation {
    condition = alltrue(flatten([
      for zone_id, vnets in var.zones : concat(
        [can(regex("^[A-Za-z][A-Za-z0-9]{1,7}$", zone_id))],
        [for vnet_id in keys(vnets) : can(regex("^[A-Za-z][A-Za-z0-9]{1,7}$", vnet_id))],
      )
    ]))
    error_message = "Zone and VNet IDs must be 2-8 alphanumeric characters starting with a letter."
  }

  validation {
    condition = alltrue(flatten([
      for vnets in values(var.zones) : [for tag in values(vnets) : tag >= 1 && tag <= 4094]
    ]))
    error_message = "VNet tags must be VLAN IDs between 1 and 4094."
  }

  # Proxmox VNet IDs are unique cluster-wide; the same name in two zones would plan fine and fail only at apply.
  validation {
    condition = (
      length(flatten([for vnets in values(var.zones) : keys(vnets)]))
      == length(distinct(flatten([for vnets in values(var.zones) : keys(vnets)])))
    )
    error_message = "VNet IDs must be unique across all zones."
  }
}

variable "bridge" {
  description = "Linux or OVS bridge, present on every node, that carries all zones."
  type        = string
  nullable    = false

  validation {
    condition     = trimspace(var.bridge) != ""
    error_message = "bridge must name an existing bridge, e.g. vmbr0."
  }
}

variable "ipam" {
  description = "IPAM plugin used by all zones. Null leaves the zones without IPAM."
  type        = string
  default     = "pve"
}
