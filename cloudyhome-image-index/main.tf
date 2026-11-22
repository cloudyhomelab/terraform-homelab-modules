data "http" "index" {
  url = "${trimsuffix(var.index_base_url, "/")}/${var.image}/index.json"

  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && can(jsondecode(self.response_body).BUILDS)
      error_message = "${self.url} returned HTTP ${self.status_code} instead of an index with BUILDS."
    }

    # An unreadable body is reported by the first postcondition
    postcondition {
      condition = try(alltrue(flatten([
        for entry in jsondecode(self.response_body).BUILDS : [
          for share in coalesce(try(entry.STORAGE, null), []) : try(trimspace(share.app) != "" && trimspace(share.dataset) != "", false)
        ]
      ])), true)
      error_message = "${self.url} lists a STORAGE entry without a non-empty app and dataset."
    }

    postcondition {
      condition     = try(contains([for entry in jsondecode(self.response_body).BUILDS : entry.BUILD_VERSION], var.image_version), true)
      error_message = "${self.url} lacks image version ${var.image_version}."
    }

    postcondition {
      condition = try(alltrue([
        for entry in jsondecode(self.response_body).BUILDS : try(
          trimspace(entry.IMAGE_URL) != "" && trimspace(entry.IMAGE_FILE) != "" && can(regex("^[A-Za-z0-9]+:[0-9A-Fa-f]+$", entry.IMAGE_CHECKSUM)),
          false
        ) if entry.BUILD_VERSION == var.image_version
      ]), true)
      error_message = "${self.url}: image version ${var.image_version} lacks IMAGE_URL, IMAGE_FILE or an IMAGE_CHECKSUM of the form <algorithm>:<hex>."
    }
  }
}

locals {
  entry    = one([for entry in jsondecode(data.http.index.response_body).BUILDS : entry if entry.BUILD_VERSION == var.image_version])
  checksum = split(":", local.entry.IMAGE_CHECKSUM)
}
