variable "role_id" {
  description = "Name of the Proxmox role granted to the user."
  type        = string
  default     = "terraform-privileges"
}

variable "privileges" {
  description = "Privileges of the role. Null uses the defaults in privileges.json."
  type        = set(string)
  default     = null
}

variable "user_id" {
  description = "Proxmox user to create, as name@realm."
  type        = string
  default     = "terraform@pve"

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+$", var.user_id))
    error_message = "user_id must have the form name@realm."
  }
}

variable "token_name" {
  description = "Name of the API token created for the user."
  type        = string
  default     = "terraform"
}

variable "expiration_date" {
  description = "RFC 3339 timestamp at which the user and the token expire."
  type        = string

  validation {
    condition     = can(formatdate("YYYY", var.expiration_date))
    error_message = "expiration_date must be an RFC 3339 timestamp, e.g. 2027-01-01T00:00:00Z."
  }
}

variable "comment" {
  description = "Comment set on the user and the token."
  type        = string
  default     = "to be used by terraform"
}
