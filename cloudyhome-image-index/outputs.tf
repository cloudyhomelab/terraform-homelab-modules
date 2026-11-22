output "image_version" {
  description = "Pinned image version."
  value       = var.image_version
}

output "download" {
  description = "Content type, URL, file name and checksum of the image version, without a target storage."
  value = {
    content_type       = "import"
    download_url       = local.entry.IMAGE_URL
    save_file_name     = local.entry.IMAGE_FILE
    checksum_algorithm = split(":", local.entry.IMAGE_CHECKSUM)[0]
    checksum           = split(":", local.entry.IMAGE_CHECKSUM)[1]
  }

  precondition {
    condition     = length(local.matches) == 1
    error_message = "${data.http.index.url} lists image version ${var.image_version} ${length(local.matches)} times instead of once."
  }

  precondition {
    condition = length(local.matches) != 1 || try(
      trimspace(local.entry.IMAGE_URL) != "" && trimspace(local.entry.IMAGE_FILE) != "" && can(regex("^[A-Za-z0-9]+:[0-9A-Fa-f]+$", local.entry.IMAGE_CHECKSUM)),
      false
    )
    error_message = "${data.http.index.url}: image version ${var.image_version} lacks IMAGE_URL, IMAGE_FILE or an IMAGE_CHECKSUM of the form <algorithm>:<hex>."
  }
}

output "storage" {
  description = "The image version's STORAGE as a list of {app, dataset, recordsize}, recordsize null when absent; empty when it declares none."
  value = [
    for share in local.storage : {
      app        = share.app
      dataset    = share.dataset
      recordsize = try(share.recordsize, null)
    }
  ]

  precondition {
    condition     = length(local.matches) == 1
    error_message = "${data.http.index.url} lists image version ${var.image_version} ${length(local.matches)} times instead of once."
  }

  precondition {
    condition     = alltrue([for share in local.storage : try(trimspace(share.app) != "" && trimspace(share.dataset) != "", false)])
    error_message = "${data.http.index.url}: image version ${var.image_version} has a STORAGE entry without a non-empty app and dataset."
  }
}
