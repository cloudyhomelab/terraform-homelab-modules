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
  }
}

locals {
  matches = [
    for entry in jsondecode(data.http.index.response_body).BUILDS : entry if try(entry.BUILD_VERSION == var.image_version, false)
  ]

  # Null unless listed exactly once; the output preconditions report that before any value is read
  entry   = try(one(local.matches), null)
  storage = coalesce(try(local.entry.STORAGE, null), [])
}
