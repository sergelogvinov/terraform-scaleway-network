
resource "scaleway_s2s_vpn_gateway" "peer" {
  for_each           = { for idx, name in var.regions : name => idx if try(var.capabilities[name].network_peer_enable, false) }
  name               = "peer-${each.key}"
  zone               = each.key
  gateway_type       = try(var.capabilities[each.key].network_peer_type, "VGW-XXS")
  private_network_id = scaleway_vpc_private_network.public[each.key].id
  tags               = var.tags
}

data "scaleway_ipam_ip" "peer_v4" {
  for_each   = { for idx, name in var.regions : name => idx if try(var.capabilities[name].network_peer_enable, false) }
  ipam_ip_id = one(scaleway_s2s_vpn_gateway.peer[each.key].public_config).ipam_ipv4_id
}

data "scaleway_ipam_ip" "peer_v6" {
  for_each   = { for idx, name in var.regions : name => idx if try(var.capabilities[name].network_peer_enable, false) }
  ipam_ip_id = one(scaleway_s2s_vpn_gateway.peer[each.key].public_config).ipam_ipv6_id
}

resource "scaleway_s2s_vpn_routing_policy" "peer_policy_v4" {
  count             = length(var.network_peering) > 0 ? 1 : 0
  name              = "peer-default-v4"
  prefix_filter_in  = try([for ip in var.network_cidr : ip if length(split(".", ip)) > 1], [])
  prefix_filter_out = flatten([for idx, zone in var.regions : local.network_subnet_v4[zone]])
  tags              = var.tags
}

resource "scaleway_s2s_vpn_routing_policy" "peer_policy_v6" {
  count             = length(var.network_peering) > 0 ? 1 : 0
  name              = "peer-default-v6"
  is_ipv6           = true
  prefix_filter_in  = try([for ip in var.network_cidr : ip if length(split(":", ip)) > 1], [])
  prefix_filter_out = flatten([for idx, zone in var.regions : local.network_subnet_v6[zone]])
  tags              = var.tags
}

locals {
  ipsec_tunnels_p2p = { for k in flatten([
    for idx, region in var.regions : [
      for peer, v in try(var.network_peering[region], {}) : {
        name = "${peer}-${region}"
        v4   = one([for ip in v.p2p : ip if length(split(".", ip)) > 1])
        v6   = one([for ip in v.p2p : ip if length(split(":", ip)) > 1])
      }
    ] if try(var.capabilities[region].network_peer_enable, false)
  ]) : k.name => k }

  ipsec_tunnels = { for k in flatten([
    for idx, region in var.regions : [
      for peer, v in try(var.network_peering[region], {}) : {
        name : "${peer}-${region}"
        region   = region
        p2p_side = v.p2p_side
        p2p_v4   = local.ipsec_tunnels_p2p["${peer}-${region}"].v4
        p2p_v6   = local.ipsec_tunnels_p2p["${peer}-${region}"].v6

        server_v4     = try(data.scaleway_ipam_ip.peer_v4[region].address, "")
        server_v6     = try(data.scaleway_ipam_ip.peer_v6[region].address, "")
        server_p2p_v4 = local.ipsec_tunnels_p2p["${peer}-${region}"].v4 != null ? cidrhost(local.ipsec_tunnels_p2p["${peer}-${region}"].v4, v.p2p_side) : ""
        server_p2p_v6 = local.ipsec_tunnels_p2p["${peer}-${region}"].v6 != null ? cidrhost(local.ipsec_tunnels_p2p["${peer}-${region}"].v6, v.p2p_side) : ""
        server_asn    = 12876

        peer_v4     = length(split(".", v.ip)) > 1 ? v.ip : null
        peer_v6     = length(split(":", v.ip)) > 1 ? v.ip : null
        peer_p2p_v4 = local.ipsec_tunnels_p2p["${peer}-${region}"].v4 != null ? cidrhost(local.ipsec_tunnels_p2p["${peer}-${region}"].v4, 1 - v.p2p_side) : ""
        peer_p2p_v6 = local.ipsec_tunnels_p2p["${peer}-${region}"].v6 != null ? cidrhost(local.ipsec_tunnels_p2p["${peer}-${region}"].v6, 1 - v.p2p_side) : ""
        peer_asn    = v.asn
      }
    ] if try(var.capabilities[region].network_peer_enable, false)
  ]) : k.name => k }
}

resource "scaleway_s2s_vpn_customer_gateway" "peer" {
  for_each    = local.ipsec_tunnels
  name        = each.key
  ipv4_public = each.value.peer_v4
  ipv6_public = each.value.peer_v6
  asn         = each.value.peer_asn
  tags        = var.tags
}

resource "scaleway_s2s_vpn_connection" "peer" {
  for_each = local.ipsec_tunnels
  name     = each.key
  region   = local.region
  tags     = var.tags

  vpn_gateway_id           = scaleway_s2s_vpn_gateway.peer[each.value.region].id
  customer_gateway_id      = scaleway_s2s_vpn_customer_gateway.peer[each.key].id
  initiation_policy        = "customer_gateway"
  enable_route_propagation = true

  dynamic "bgp_config_ipv4" {
    for_each = each.value.peer_p2p_v4 != "" && each.value.server_p2p_v4 != "" ? [1] : []
    content {
      private_ip        = "${each.value.server_p2p_v4}/31"
      peer_private_ip   = "${each.value.peer_p2p_v4}/31"
      routing_policy_id = scaleway_s2s_vpn_routing_policy.peer_policy_v4[0].id
    }
  }
  dynamic "bgp_config_ipv6" {
    for_each = each.value.peer_p2p_v6 != "" && each.value.server_p2p_v6 != "" ? [1] : []
    content {
      # Bug?, using auto assigned ip for bgp session
      #
      # private_ip        = "${each.value.server_p2p_v6}/127"
      # peer_private_ip   = "${each.value.peer_p2p_v6}/127"
      routing_policy_id = scaleway_s2s_vpn_routing_policy.peer_policy_v6[0].id
    }
  }

  ikev2_ciphers {
    encryption = "aes256"
    integrity  = "sha256"
    dh_group   = "modp2048"
  }
  esp_ciphers {
    encryption = "aes256"
    integrity  = "sha256"
    dh_group   = "modp2048"
  }
}
