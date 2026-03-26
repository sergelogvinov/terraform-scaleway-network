
variable "regions" {
  description = "The list of the scaleway region name (order is important)"
  type        = list(string)
  default     = ["fr-par-1", "fr-par-2"]
}

variable "network_region" {
  description = "Default region"
  type        = string
  default     = ""
}

variable "network_name" {
  type    = string
  default = "main"
}

variable "network_cidr" {
  description = "Local subnet rfc1918"
  type        = list(string)
  default     = ["172.28.0.0/16", "fd60:172:28::/56"]

  validation {
    condition     = length(var.network_cidr) == 2
    error_message = "The network_cidr is a list of IPv4/IPv6 cidr."
  }
}

variable "network_shift" {
  description = "Network number shift"
  type        = number
  default     = 1
}

# curl https://www.cloudflare.com/ips-v4 2>/dev/null | awk '{ print "\""$1"\"," }'
variable "whitelist_web" {
  description = "Cloudflare subnets"
  default = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22",
  ]
}

variable "allowlist_datacenters" {
  description = "Datacenters subnets"
  default     = []
}

variable "allowlist_admins" {
  description = "Whitelist for administrators"
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags of resources"
  type        = list(string)
  default     = ["develop"]
}

variable "capabilities" {
  type = map(any)
  default = {
    "fr-par-1" = {
      network_nat_enable = false
      network_nat_type   = "VPC-GW-S"
    },
    "fr-par-2" = {
      network_nat_enable = false
      network_nat_type   = "VPC-GW-S"
    },
  }
}
