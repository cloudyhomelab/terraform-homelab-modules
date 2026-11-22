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
    checksum_algorithm = local.checksum[0]
    checksum           = local.checksum[1]
  }
}

output "storage" {
  description = "The image version's STORAGE as a list of {app, dataset, recordsize}, recordsize null when absent; empty when it declares none."
  value = [
    for share in coalesce(try(local.entry.STORAGE, null), []) : {
      app        = share.app
      dataset    = share.dataset
      recordsize = try(share.recordsize, null)
    }
  ]
}
