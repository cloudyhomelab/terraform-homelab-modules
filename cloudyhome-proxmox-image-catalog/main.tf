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
  }
}

locals {
  builds = merge([
    for key, index in data.http.index : {
      for build in jsondecode(index.response_body).BUILDS : "${key}/${build.BUILD_VERSION}" => {
        os        = local.image_types[key].os
        type      = local.image_types[key].type
        version   = build.BUILD_VERSION
        url       = build.IMAGE_URL
        file_name = build.IMAGE_FILE
        checksum  = split(":", build.IMAGE_CHECKSUM)
      }
    }
  ]...)
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
