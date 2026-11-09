locals {
  zone         = "${trimsuffix(var.config.zone, ".")}."
  reverse_zone = "${trimsuffix(var.config.reverse_zone, ".")}."
  fqdn         = "${var.config.name}.${local.zone}"

  ptr_fqdn = var.config.ipv4 != null ? "${join(".", reverse(split(".", var.config.ipv4)))}.in-addr.arpa." : null
  # Relative to the zone, so the zone may cover a /8, /16 or /24.
  ptr_name = local.ptr_fqdn != null ? trimsuffix(local.ptr_fqdn, ".${local.reverse_zone}") : null
}

resource "dns_a_record_set" "this" {
  zone      = local.zone
  name      = var.config.name
  addresses = [var.config.ipv4]
  ttl       = var.config.ttl

  lifecycle {
    precondition {
      condition     = var.config.ipv4 != null
      error_message = "No IPv4 address given for ${var.config.name}; cannot create its DNS records."
    }
  }
}

resource "dns_ptr_record" "this" {
  zone = local.reverse_zone
  name = local.ptr_name
  ptr  = local.fqdn
  ttl  = var.config.ttl

  lifecycle {
    precondition {
      condition     = local.ptr_fqdn != null && endswith(local.ptr_fqdn, ".${local.reverse_zone}")
      error_message = "The address of ${var.config.name} is unknown or not in reverse zone ${var.config.reverse_zone}; cannot create the PTR record."
    }
  }
}
