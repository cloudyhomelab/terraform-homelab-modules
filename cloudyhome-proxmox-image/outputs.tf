output "file_ids" {
  description = "File IDs (<datastore>:<content type>/<file name>) keyed by node, for use as a VM disk or CD-ROM file_id."
  value       = { for node, file in proxmox_download_file.this : node => file.id }
}

output "file_name" {
  description = "File name on the storage, identical on every node."
  value       = one(distinct([for file in proxmox_download_file.this : file.file_name]))
}
