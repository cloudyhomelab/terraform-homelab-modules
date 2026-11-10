locals {
  index_base_url = trimsuffix(var.index_base_url, "/")

  image_types = merge([
    for os, types in var.images : { for type in types : "${os}/${type}" => { os = os, type = type } }
  ]...)
}

data "http" "index" {
  for_each = local.image_types

  url = "${local.index_base_url}/${each.key}/index.json"

  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && can(jsondecode(self.response_body).BUILDS)
      error_message = "${self.url} returned HTTP ${self.status_code} instead of an index with BUILDS."
    }

    # An unreadable body is reported by the postcondition
    postcondition {
      condition = try(alltrue(flatten([
        for build in jsondecode(self.response_body).BUILDS : [
          for share in coalesce(try(build.STORAGE, null), []) : try(trimspace(share.app) != "" && trimspace(share.dataset) != "", false)
        ]
      ])), true)
      error_message = "${self.url} lists a STORAGE entry without a non-empty app and dataset."
    }
  }
}

locals {
  indexed_builds = merge([
    for key, index in data.http.index : {
      for build in jsondecode(index.response_body).BUILDS : "${key}/${build.BUILD_VERSION}" => {
        os        = local.image_types[key].os
        type      = local.image_types[key].type
        version   = build.BUILD_VERSION
        url       = build.IMAGE_URL
        file_name = build.IMAGE_FILE
        checksum  = split(":", build.IMAGE_CHECKSUM)
        storage   = coalesce(try(build.STORAGE, null), [])
      }
    }
  ]...)

  # BUILD_VERSION is a sortable timestamp; the index order is not relied on.
  indexed_versions = {
    for key in keys(local.image_types) : key => sort([
      for build in values(local.indexed_builds) : build.version if "${build.os}/${build.type}" == key
    ])
  }

  versions = {
    for key, versions in local.indexed_versions : key => (
      var.keep_latest == null ? versions : slice(versions, max(0, length(versions) - var.keep_latest), length(versions))
    )
  }

  builds = {
    for key, build in local.indexed_builds : key => build if contains(local.versions["${build.os}/${build.type}"], build.version)
  }
}

module "image" {
  source   = "../cloudyhome-proxmox-image"
  for_each = local.builds

  config = {
    datastore_id       = var.datastore_id
    content_type       = "import"
    download_url       = each.value.url
    save_file_name     = each.value.file_name
    checksum_algorithm = each.value.checksum[0]
    checksum           = each.value.checksum[1]
  }
}
