
terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.70.1"
    }
  }
  required_version = ">= 1.5"
}
