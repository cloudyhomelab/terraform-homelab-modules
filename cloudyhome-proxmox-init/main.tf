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

  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.this.role_id
  }
}

resource "proxmox_user_token" "this" {
  comment               = var.comment
  expiration_date       = var.expiration_date
  token_name            = var.token_name
  user_id               = proxmox_virtual_environment_user.this.user_id
  privileges_separation = false
}

moved {
  from = proxmox_virtual_environment_user_token.this
  to   = proxmox_user_token.this
}
