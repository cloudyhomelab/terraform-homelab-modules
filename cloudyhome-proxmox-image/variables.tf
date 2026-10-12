variable "config" {
  description = "File to download from a URL onto a Proxmox storage of every node in the cluster."
  type = object({
    datastore_id            = optional(string, "local")
    content_type            = optional(string, "iso")
    download_url            = string
    save_file_name          = optional(string, null)
    checksum                = string
    checksum_algorithm      = string
    decompression_algorithm = optional(string, null)
    overwrite               = optional(bool, true)
  })

  validation {
    condition     = trimspace(var.config.datastore_id) != ""
    error_message = "config.datastore_id must name an existing storage, e.g. local."
  }

  validation {
    condition     = contains(["iso", "import", "vztmpl"], var.config.content_type)
    error_message = "config.content_type must be iso, import or vztmpl."
  }

  # Proxmox rejects other names at apply time, after the plan has passed.
  validation {
    condition = (
      var.config.content_type != "iso"
      || (
        var.config.save_file_name != null
        ? can(regex("\\.(iso|img)$", var.config.save_file_name))
        : can(regex("\\.(iso|img)([?#].*)?$", var.config.download_url))
      )
    )
    error_message = "Files of content type iso must be named *.iso or *.img; set config.save_file_name when the URL ends otherwise."
  }

  validation {
    condition = (
      !can(regex("\\.xz([?#].*)?$", var.config.download_url))
      || var.config.decompression_algorithm == "zst"
    )
    error_message = "config.decompression_algorithm must be zst for an .xz download."
  }

  validation {
    condition     = var.config.checksum != null && trimspace(var.config.checksum) != ""
    error_message = "config.checksum must be the expected checksum of the downloaded file."
  }

  validation {
    condition     = var.config.checksum_algorithm != null && trimspace(var.config.checksum_algorithm) != ""
    error_message = "config.checksum_algorithm must name the checksum algorithm, e.g. sha256."
  }
}
