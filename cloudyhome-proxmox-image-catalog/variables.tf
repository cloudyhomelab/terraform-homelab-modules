variable "index_base_url" {
  description = "Base URL under which every image type publishes <os>/<type>/index.json."
  type        = string

  validation {
    condition     = can(regex("^https?://[^/]+", var.index_base_url))
    error_message = "index_base_url must be an http(s) URL, e.g. https://s3.example.com/os-images."
  }
}

variable "images" {
  description = "Image types to download, as lists of types keyed by OS."
  type        = map(list(string))

  validation {
    condition = alltrue(flatten([
      for os, types in var.images : [for type in concat([os], types) : can(regex("^[A-Za-z0-9._-]+$", type))]
    ]))
    error_message = "images keys and types must be non-empty path segments of letters, digits, '.', '_' or '-'."
  }
}

variable "datastore_id" {
  description = "Storage the images are saved on; it must allow content type import."
  type        = string
  default     = "local"

  validation {
    condition     = trimspace(var.datastore_id) != ""
    error_message = "datastore_id must name an existing storage, e.g. local."
  }
}
