
locals {
  network_cidr_v4 = try(one([for ip in var.network_cidr : ip if length(split(".", ip)) > 1]), "")
  network_cidr_v6 = try(one([for ip in var.network_cidr : ip if length(split(":", ip)) > 1]), "")

  region = var.network_region == "" ? substr(var.regions[0], 0, 6) : var.network_region
}

resource "scaleway_vpc" "main" {
  name = var.network_name
  tags = var.tags
}

resource "scaleway_vpc_private_network" "public" {
  for_each = { for idx, name in var.regions : name => idx }
  vpc_id   = scaleway_vpc.main.id
  name     = "public-${each.key}"
  region   = local.region
  tags     = var.tags

  ipv4_subnet {
    subnet = cidrsubnet(local.network_cidr_v4, 8, (var.network_shift + each.value) * 4)
  }
  ipv6_subnets {
    subnet = cidrsubnet(local.network_cidr_v6, 8, 4 * (var.network_shift + each.value))
  }
}

resource "scaleway_vpc_private_network" "elasticmetal" {
  for_each = { for idx, name in var.regions : name => idx }
  vpc_id   = scaleway_vpc.main.id
  name     = "elasticmetal-${each.key}"
  region   = local.region
  tags     = var.tags

  enable_default_route_propagation = true
  ipv4_subnet {
    subnet = cidrsubnet(local.network_cidr_v4, 8, 2 + (var.network_shift + each.value) * 4)
  }
  ipv6_subnets {
    subnet = cidrsubnet(local.network_cidr_v6, 8, 2 + 4 * (var.network_shift + each.value))
  }
}

resource "scaleway_vpc_private_network" "private" {
  for_each = { for idx, name in var.regions : name => idx }
  vpc_id   = scaleway_vpc.main.id
  name     = "private-${each.key}"
  region   = local.region
  tags     = var.tags

  enable_default_route_propagation = true
  ipv4_subnet {
    subnet = cidrsubnet(local.network_cidr_v4, 8, 1 + (var.network_shift + each.value) * 4)
  }
  ipv6_subnets {
    subnet = cidrsubnet(local.network_cidr_v6, 8, 1 + 4 * (var.network_shift + each.value))
  }
}

resource "scaleway_vpc_public_gateway_ip" "main" {
  for_each = { for idx, name in var.regions : name => idx if try(var.capabilities[name].network_nat_enable, false) }
  zone     = each.key
  tags     = var.tags
}

resource "scaleway_vpc_public_gateway" "main" {
  for_each = { for idx, name in var.regions : name => idx if try(var.capabilities[name].network_nat_enable, false) }
  name     = "main"
  zone     = each.key
  type     = try(var.capabilities["all"].network_nat_type, "VPC-GW-S")
  ip_id    = scaleway_vpc_public_gateway_ip.main[each.key].id

  allowed_ip_ranges = [for ip in var.allowlist_admins : ip if length(split(".", ip)) > 1]
  tags              = var.tags
}

resource "scaleway_vpc_gateway_network" "main" {
  for_each           = { for idx, name in var.regions : name => idx if try(var.capabilities[name].network_nat_enable, false) }
  zone               = each.key
  gateway_id         = scaleway_vpc_public_gateway.main[each.key].id
  private_network_id = scaleway_vpc_private_network.private[each.key].id

  enable_masquerade = true
  ipam_config {
    push_default_route = true
  }
}
