terraform {
  required_version = ">= 1.10.6"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.115.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.9.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.6.2"
    }
  }
}
