variable "root" {
  description = "Existing dataset under which every app gets its own dataset, e.g. tank/app_data."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[^/]+(/[^/]+)*$", var.root))
    error_message = "root must be a dataset path without leading or trailing slash, e.g. tank/app_data."
  }
}

variable "clients" {
  description = "Client key => the datasets it uses, each as {app, dataset, recordsize?}, and its IPv4 address; a client without an address keeps its datasets and gets no access."
  type = map(object({
    storage = list(object({
      app        = string
      dataset    = string
      recordsize = optional(string)
    }))
    address = optional(string)
  }))
  nullable = false

  validation {
    # app and dataset become ZFS and filesystem path segments
    condition = alltrue(flatten([
      for client in values(var.clients) : [
        for entry in client.storage :
        can(regex("^[A-Za-z0-9_-][A-Za-z0-9._-]*$", entry.app)) && can(regex("^[A-Za-z0-9_-][A-Za-z0-9._-]*$", entry.dataset))
      ]
    ]))
    error_message = "Every storage app and dataset must match ^[A-Za-z0-9_-][A-Za-z0-9._-]*$."
  }

  validation {
    # cidrnetmask accepts IPv4 only, unlike cidrhost
    condition     = alltrue([for client in values(var.clients) : client.address == null || can(cidrnetmask("${client.address}/32"))])
    error_message = "A client address must be a bare IPv4 address, e.g. 192.0.2.10."
  }
}
