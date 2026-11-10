terraform {
  required_version = ">= 1.11.2"

  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = ">= 6.0.0"
    }
  }
}
