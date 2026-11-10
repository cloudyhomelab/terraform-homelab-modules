terraform {
  required_version = ">= 1.11.2"

  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = ">= 3.6.2"
    }
  }
}
