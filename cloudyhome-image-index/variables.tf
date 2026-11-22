variable "index_base_url" {
  description = "Base URL under which every image publishes <os>/<type>/index.json."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^https?://[^/]+", var.index_base_url))
    error_message = "index_base_url must be an http(s) URL, e.g. https://s3.example.com/os-images."
  }
}

variable "image" {
  description = "Image as <os>/<type>."
  type        = string
  nullable    = false

  validation {
    # image becomes two URL path segments
    condition     = can(regex("^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$", var.image))
    error_message = "image must be <os>/<type>, each a path segment of letters, digits, '.', '_' or '-'."
  }
}

variable "image_version" {
  description = "Pinned image version, as listed in the image's index."
  type        = string
  nullable    = false

  validation {
    condition     = trimspace(var.image_version) != ""
    error_message = "image_version must be a non-empty image version."
  }
}
