
output "regions" {
  description = "Regions"
  value       = var.regions
}

output "tags" {
  description = "Common tags"
  value       = var.tags
}

output "network_public" {
  description = "The public network"
  value = { for idx, zone in var.regions : zone => {
    network_id = scaleway_vpc.main.id
    subnet_id  = scaleway_vpc_private_network.public[zone].id
    cidr_v4    = scaleway_vpc_private_network.public[zone].ipv4_subnet[0].subnet
    cidr_v6    = one(scaleway_vpc_private_network.public[zone].ipv6_subnets).subnet
    gateway_v4 = cidrhost(scaleway_vpc_private_network.public[zone].ipv4_subnet[0].subnet, 1)
    gateway_v6 = cidrhost(one(scaleway_vpc_private_network.public[zone].ipv6_subnets).subnet, 1)
    mtu        = 1500
  } }
}

output "network_private" {
  description = "The private network"
  value = { for idx, zone in var.regions : zone => {
    network_id = scaleway_vpc.main.id
    subnet_id  = scaleway_vpc_private_network.private[zone].id
    cidr_v4    = scaleway_vpc_private_network.private[zone].ipv4_subnet[0].subnet
    cidr_v6    = one(scaleway_vpc_private_network.private[zone].ipv6_subnets).subnet
    gateway_v4 = cidrhost(scaleway_vpc_private_network.private[zone].ipv4_subnet[0].subnet, 1)
    gateway_v6 = cidrhost(one(scaleway_vpc_private_network.private[zone].ipv6_subnets).subnet, 1)
    mtu        = 1500
  } }
}

output "network_baremetal" {
  description = "The baremetal network"
  value = { for idx, zone in var.regions : zone => {
    cidr_v4    = cidrsubnet(local.network_cidr_v4, 8, 2 + (var.network_shift + idx) * 4)
    cidr_v6    = cidrsubnet(local.network_cidr_v6, 8, 2 + 4 * (var.network_shift + idx))
    gateway_v4 = cidrhost(cidrsubnet(local.network_cidr_v4, 8, 2 + (var.network_shift + idx) * 4), 1)
    gateway_v6 = cidrhost(cidrsubnet(local.network_cidr_v6, 8, 2 + 4 * (var.network_shift + idx)), 1)
    mtu        = 1500
  } }
}

output "network_nat" {
  description = "The nat ips"
  value = { for idx, zone in var.regions : zone => {
    ip_v4 = scaleway_vpc_public_gateway_ip.main[zone].address
  } if try(var.capabilities[zone].network_nat_enable, false) }
}

output "network_secgroup" {
  description = "The Network Security Groups"
  value = { for idx, zone in var.regions : zone => {
    common       = scaleway_instance_security_group.common[zone].id
    controlplane = scaleway_instance_security_group.controlplane[zone].id
    web          = scaleway_instance_security_group.web[zone].id
  } }
}
