output "file_ids" {
  description = "File IDs (<datastore>:<content type>/<file name>) keyed by node, for use as a VM disk or CD-ROM file_id."
  value       = { for node, file in proxmox_download_file.this : node => file.id }
}

output "file_name" {
  description = "File name on the storage, identical on every node."
  # Taken from id, which stays unknown until the download exists, so a data lookup by this name in the same plan waits for it.
  value = one(distinct([for file in proxmox_download_file.this : split("/", file.id)[1]]))
}

output "content_type" {
  description = "Content type the file is stored as."
  value       = var.config.content_type
}

output "datastore_id" {
  description = "Storage the file is saved on."
  value       = var.config.datastore_id
}
