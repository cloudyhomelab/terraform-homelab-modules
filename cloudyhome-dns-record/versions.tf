terraform {
  required_version = ">= 1.10.6"

  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = ">= 3.6.2"
    }
  }
}
