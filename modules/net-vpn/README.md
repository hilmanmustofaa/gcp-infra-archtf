# VPN Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module manages Google Cloud VPN resources, including external VPN gateways, HA VPN gateways, and VPN tunnels.

# Feature
- **External VPN Gateways**: create external VPN gateways.
- **HA VPN Gateways**: create highly available VPN gateways.
- **VPN Tunnels**: create VPN tunnels.
- **Flexible Naming**: support `resource_prefix` and `join_separator` for consistent naming conventions.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_external_vpn_gateways](variables.tf#L1) | A map of external VPN gateway objects. | <code title="map&#40;object&#40;&#123;&#10;  name            &#61; string&#10;  description     &#61; optional&#40;string&#41;&#10;  labels          &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  redundancy_type &#61; optional&#40;string, &#34;SINGLE_IP_INTERNALLY_REDUNDANT&#34;&#41;&#10;  interface &#61; list&#40;object&#40;&#123;&#10;    id         &#61; number&#10;    ip_address &#61; string&#10;  &#125;&#41;&#41;&#10;  project &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [compute_ha_vpn_gateways](variables.tf#L17) | A map of HA VPN gateway objects. | <code title="map&#40;object&#40;&#123;&#10;  name        &#61; string&#10;  network     &#61; string&#10;  description &#61; optional&#40;string&#41;&#10;  vpn_interfaces &#61; list&#40;object&#40;&#123;&#10;    id                      &#61; number&#10;    ip_address              &#61; optional&#40;string&#41;&#10;    interconnect_attachment &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;  region  &#61; string&#10;  project &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [compute_vpn_tunnels](variables.tf#L34) | A map of VPN tunnel objects. | <code title="map&#40;object&#40;&#123;&#10;  name                            &#61; string&#10;  shared_secret                   &#61; optional&#40;string&#41;&#10;  description                     &#61; optional&#40;string&#41;&#10;  vpn_gateway                     &#61; optional&#40;string&#41;&#10;  vpn_gateway_interface           &#61; optional&#40;number&#41;&#10;  peer_external_gateway           &#61; optional&#40;string&#41;&#10;  peer_external_gateway_interface &#61; optional&#40;number&#41;&#10;  peer_gcp_gateway                &#61; optional&#40;string&#41;&#10;  router                          &#61; optional&#40;string&#41;&#10;  peer_ip                         &#61; optional&#40;string&#41;&#10;  ike_version                     &#61; optional&#40;number, 2&#41;&#10;  local_traffic_selector          &#61; optional&#40;list&#40;string&#41;, &#91;&#34;0.0.0.0&#47;0&#34;&#93;&#41;&#10;  remote_traffic_selector         &#61; optional&#40;list&#40;string&#41;, &#91;&#34;0.0.0.0&#47;0&#34;&#93;&#41;&#10;  labels                          &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  region                          &#61; string&#10;  project                         &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [default_labels](variables.tf#L57) | Default labels to apply to all resources. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L63) | The separator to use when joining the prefix and the name. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L69) | A prefix for the resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [external_vpn_gateways](outputs.tf#L1) | The created external VPN gateways. |  |
| [ha_vpn_gateways](outputs.tf#L6) | The created HA VPN gateways. |  |
| [vpn_tunnels](outputs.tf#L11) | The created VPN tunnels. | ✓ |
<!-- END TFDOC -->
# Example Usage

```hcl
module "vpn" {
  source = "./modules/net-vpn"

  compute_ha_vpn_gateways = {
    "my-ha-vpn-gateway" = {
      name    = "my-ha-vpn-gateway"
      network = "my-network-self-link"
      project = "my-project"
      region  = "us-central1"
    }
  }

  compute_vpn_tunnels = {
    "my-vpn-tunnel" = {
      name                  = "my-vpn-tunnel"
      vpn_gateway           = "my-ha-vpn-gateway-self-link"
      peer_ip               = "1.2.3.4"
      ike_version           = 2
      shared_secret         = "a-very-secret-key"
      local_traffic_selector  = ["0.0.0.0/0"]
      remote_traffic_selector = ["10.0.0.0/8"]
      project               = "my-project"
      region                = "us-central1"
    }
  }
}
