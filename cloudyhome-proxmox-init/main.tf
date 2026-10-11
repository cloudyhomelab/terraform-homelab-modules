locals {
  privileges = (
    var.privileges != null ? var.privileges : jsondecode(file("${path.module}/privileges.json"))
  )
}

resource "proxmox_virtual_environment_role" "this" {
  role_id    = var.role_id
  privileges = local.privileges
}

resource "proxmox_virtual_environment_user" "this" {
  user_id         = var.user_id
  comment         = var.comment
  expiration_date = var.expiration_date
  enabled         = true
}

resource "proxmox_acl" "this" {
  path      = "/"
  propagate = true
  role_id   = proxmox_virtual_environment_role.this.role_id
  user_id   = proxmox_virtual_environment_user.this.user_id
}

resource "proxmox_user_token" "this" {
  comment               = var.comment
  expiration_date       = var.expiration_date
  token_name            = var.token_name
  user_id               = proxmox_virtual_environment_user.this.user_id
  privileges_separation = false

  # The token is unusable until the user's ACL exists.
  depends_on = [proxmox_acl.this]
}
