terraform {
  required_version = ">= 1.10.6"

  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = ">= 6.0.0"
    }
  }
}
