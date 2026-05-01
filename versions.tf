
terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.74.0"
    }
  }
  required_version = ">= 1.5"
}
