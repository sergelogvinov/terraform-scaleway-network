# Terraform module for Scaleway Cloud

## Overview

## Usage Example

```hcl
module "network" {
  source = "github.com/sergelogvinov/terraform-scaleway-network"

  regions = ["fr-par-1", "fr-par-2"]

  network_name    = "main"
  network_cidr    = ["172.16.0.0/16", "fd60:172:16::/56"]
  network_shift   = 2

  allowlist_datacenters = ["123.123.123.0/24"]
  allowlist_admins      = ["1.2.3.4/32"]

  tags = ["rnd"] {
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | ~> 2.70.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | ~> 2.70.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_instance_security_group.common](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_security_group) | resource |
| [scaleway_instance_security_group.controlplane](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_security_group) | resource |
| [scaleway_instance_security_group.web](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_security_group) | resource |
| [scaleway_vpc.main](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc) | resource |
| [scaleway_vpc_gateway_network.main](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_gateway_network) | resource |
| [scaleway_vpc_private_network.private](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_private_network) | resource |
| [scaleway_vpc_private_network.public](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_private_network) | resource |
| [scaleway_vpc_public_gateway.main](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway) | resource |
| [scaleway_vpc_public_gateway_ip.main](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowlist_admins"></a> [allowlist\_admins](#input\_allowlist\_admins) | Whitelist for administrators | `list` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowlist_datacenters"></a> [allowlist\_datacenters](#input\_allowlist\_datacenters) | Datacenters subnets | `list` | `[]` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | n/a | `map(any)` | <pre>{<br/>  "fr-par-1": {<br/>    "network_nat_enable": false,<br/>    "network_nat_type": "VPC-GW-S"<br/>  },<br/>  "fr-par-2": {<br/>    "network_nat_enable": false,<br/>    "network_nat_type": "VPC-GW-S"<br/>  }<br/>}</pre> | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Local subnet rfc1918 | `list(string)` | <pre>[<br/>  "172.28.0.0/16",<br/>  "fd60:172:28::/56"<br/>]</pre> | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | n/a | `string` | `"main"` | no |
| <a name="input_network_region"></a> [network\_region](#input\_network\_region) | Default region | `string` | `""` | no |
| <a name="input_network_shift"></a> [network\_shift](#input\_network\_shift) | Network number shift | `number` | `1` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | The list of the scaleway region name (order is important) | `list(string)` | <pre>[<br/>  "fr-par-1",<br/>  "fr-par-2"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags of resources | `list(string)` | <pre>[<br/>  "develop"<br/>]</pre> | no |
| <a name="input_whitelist_web"></a> [whitelist\_web](#input\_whitelist\_web) | Cloudflare subnets | `list` | <pre>[<br/>  "173.245.48.0/20",<br/>  "103.21.244.0/22",<br/>  "103.22.200.0/22",<br/>  "103.31.4.0/22",<br/>  "141.101.64.0/18",<br/>  "108.162.192.0/18",<br/>  "190.93.240.0/20",<br/>  "188.114.96.0/20",<br/>  "197.234.240.0/22",<br/>  "198.41.128.0/17",<br/>  "162.158.0.0/15",<br/>  "104.16.0.0/13",<br/>  "104.24.0.0/14",<br/>  "172.64.0.0/13",<br/>  "131.0.72.0/22"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_baremetal"></a> [network\_baremetal](#output\_network\_baremetal) | The baremetal network |
| <a name="output_network_nat"></a> [network\_nat](#output\_network\_nat) | The nat ips |
| <a name="output_network_private"></a> [network\_private](#output\_network\_private) | The private network |
| <a name="output_network_public"></a> [network\_public](#output\_network\_public) | The public network |
| <a name="output_network_secgroup"></a> [network\_secgroup](#output\_network\_secgroup) | The Network Security Groups |
| <a name="output_regions"></a> [regions](#output\_regions) | Regions |
| <a name="output_tags"></a> [tags](#output\_tags) | Common tags |
<!-- END_TF_DOCS -->