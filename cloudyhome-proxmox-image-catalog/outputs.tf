locals {
  images = {
    for key, build in local.builds : key => {
      os        = build.os
      type      = build.type
      version   = build.version
      file_name = module.image[key].file_name
      file_ids  = module.image[key].file_ids
      image = {
        file_name    = module.image[key].file_name
        content_type = module.image[key].content_type
        datastore_id = module.image[key].datastore_id
      }
    }
  }

  # BUILD_VERSION is a sortable timestamp; the index order is not relied on.
  versions = {
    for key in keys(local.image_types) : key => sort([
      for build in values(local.builds) : build.version if "${build.os}/${build.type}" == key
    ])
  }
}

output "images" {
  description = "Every downloaded build keyed by <os>/<type>/<version>, with its file name, file IDs keyed by node, and image (file_name, content_type, datastore_id) to reference the file by its parts."
  value       = local.images
}

output "latest" {
  description = "Newest build of every image type keyed by <os>/<type>, in the same shape as images."
  value = {
    for key, versions in local.versions : key => local.images["${key}/${versions[length(versions) - 1]}"] if length(versions) > 0
  }
}
