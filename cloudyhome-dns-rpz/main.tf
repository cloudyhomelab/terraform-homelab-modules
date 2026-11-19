locals {
  allow_zone = "${trimsuffix(var.config.allow_zone, ".")}."
  deny_zone  = "${trimsuffix(var.config.deny_zone, ".")}."

  deny_names = toset(flatten([for d in var.config.deny : [d, "*.${d}"]]))
}

resource "dns_cname_record" "allow" {
  for_each = var.config.allow

  zone  = local.allow_zone
  name  = each.key
  cname = "rpz-passthru."
  ttl   = var.config.ttl
}

# "CNAME ." is the RPZ action for NXDOMAIN.
resource "dns_cname_record" "deny" {
  for_each = local.deny_names

  zone  = local.deny_zone
  name  = each.key
  cname = "."
  ttl   = var.config.ttl
}
