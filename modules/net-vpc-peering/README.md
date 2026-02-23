# VPC Network Peering Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module manages Google Cloud VPC Network Peering, allowing you to connect VPC networks.

# Feature
- **Network Peering**: create and manage VPC network peerings.
- **Custom Route Exchange**: configure custom route exchange for peerings.
- **Public IP Subnet Route Exchange**: configure public IP subnet route exchange for peerings.
- **Flexible Naming**: support `resource_prefix` and `join_separator` for consistent naming conventions.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_network_peerings](variables.tf#L1) | A map of network peering objects. | <code title="map&#40;object&#40;&#123;&#10;  name                                &#61; string&#10;  network                             &#61; string&#10;  peer_network                        &#61; string&#10;  export_custom_routes                &#61; optional&#40;bool, false&#41;&#10;  import_custom_routes                &#61; optional&#40;bool, false&#41;&#10;  export_subnet_routes_with_public_ip &#61; optional&#40;bool, false&#41;&#10;  import_subnet_routes_with_public_ip &#61; optional&#40;bool, false&#41;&#10;  stack_type                          &#61; optional&#40;string, &#34;IPV4_ONLY&#34;&#41;&#10;  peer_create_peering                 &#61; optional&#40;bool, false&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L17) | The separator to use when joining the prefix and the name. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L23) | A prefix for the resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [network_peerings](outputs.tf#L1) | The created network peerings. |  |
| [network_peerings_remote](outputs.tf#L6) | The created remote network peerings. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "vpc_peering" {
  source = "./modules/net-vpc-peering"

  compute_network_peerings = {
    "my-peering" = {
      name                                = "my-peering"
      network                             = "projects/my-project/global/networks/my-network-1"
      peer_network                        = "projects/my-project/global/networks/my-network-2"
      export_custom_routes                = true
      import_custom_routes                = true
      export_subnet_routes_with_public_ip = false
      import_subnet_routes_with_public_ip = false
      stack_type                          = "IPV4_ONLY"
      peer_create_peering                 = true
    }
  }
}