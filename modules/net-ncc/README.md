# Network Connectivity Center

<!-- BEGIN TOC -->
- [Description](#description)
- [Features](#features)
- [Variables](#variables)
- [Outputs](#outputs)
- [Usage](#usage)
<!-- END TOC -->

# Description

This module creates a Google Cloud Network Connectivity Center (NCC) hub and spoke. NCC allows you to manage network connectivity between your on-premises networks, Google Cloud Virtual Private Clouds (VPCs), and other cloud providers. This module simplifies the creation of NCC hubs and spokes, allowing you to centralize your network management.

# Features

- **Hub Creation:** Creates a Network Connectivity Center hub, which acts as a central point for managing network connectivity.
- **Spoke Creation:** Creates Network Connectivity Center spokes, which represent individual network connections (e.g., VPN tunnels, VLAN attachments, Interconnect attachments).
- **Spoke Types:** Supports different spoke types, including:
    - `VPN`: Connects to VPN tunnels.
    - `VLAN`: Connects to VLAN attachments.
    - `INTERCONNECT`: Connects to Interconnect attachments.
- **Description Support:** Supports adding descriptions to both hubs and spokes for better organization and documentation.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [ncc_hub_name](variables.tf#L33) | The Name of the NCC Hub. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L38) | Project ID of the project that holds the network. | <code>string</code> | ✓ |  |
| [export_psc](variables.tf#L1) | Whether Private Service Connect transitivity is enabled for the hub. | <code>bool</code> |  | <code>false</code> |
| [hybrid_spokes](variables.tf#L7) | VLAN attachments and VPN Tunnels that are associated with the spoke. Type must be one of `interconnect` and `vpn`. | <code title="map&#40;object&#40;&#123;&#10;  location                   &#61; string&#10;  uris                       &#61; set&#40;string&#41;&#10;  site_to_site_data_transfer &#61; optional&#40;bool, false&#41;&#10;  type                       &#61; string&#10;  description                &#61; optional&#40;string&#41;&#10;  labels                     &#61; optional&#40;map&#40;string&#41;&#41;&#10;  include_import_ranges      &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L49) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [ncc_hub_description](variables.tf#L21) | The description of the NCC Hub. | <code>string</code> |  | <code>null</code> |
| [ncc_hub_labels](variables.tf#L27) | These labels will be added the NCC hub. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L43) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |
| [router_appliance_spokes](variables.tf#L55) | Router appliance instances that are associated with the spoke. | <code title="map&#40;object&#40;&#123;&#10;  instances &#61; set&#40;object&#40;&#123;&#10;    virtual_machine &#61; string&#10;    ip_address      &#61; string&#10;  &#125;&#41;&#41;&#10;  location                   &#61; string&#10;  site_to_site_data_transfer &#61; optional&#40;bool, false&#41;&#10;  description                &#61; optional&#40;string&#41;&#10;  labels                     &#61; optional&#40;map&#40;string&#41;&#41;&#10;  include_import_ranges      &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [spoke_labels](variables.tf#L71) | These labels will be added to all NCC spokes. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [vpc_spokes](variables.tf#L77) | VPC network that is associated with the spoke. link_producer_vpc_network: Producer VPC network that is peered with vpc network. | <code title="map&#40;object&#40;&#123;&#10;  uri                   &#61; string&#10;  exclude_export_ranges &#61; optional&#40;set&#40;string&#41;, &#91;&#93;&#41;&#10;  include_export_ranges &#61; optional&#40;set&#40;string&#41;, &#91;&#93;&#41;&#10;  description           &#61; optional&#40;string&#41;&#10;  labels                &#61; optional&#40;map&#40;string&#41;&#41;&#10;&#10;&#10;  link_producer_vpc_network &#61; optional&#40;object&#40;&#123;&#10;    network_name          &#61; string&#10;    peering               &#61; string&#10;    include_export_ranges &#61; optional&#40;list&#40;string&#41;&#41;&#10;    exclude_export_ranges &#61; optional&#40;list&#40;string&#41;&#41;&#10;    description           &#61; optional&#40;string&#41;&#10;    labels                &#61; optional&#40;map&#40;string&#41;&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [hybrid_spokes](outputs.tf#L1) | All hybrid spoke objects. |  |
| [ncc_hub](outputs.tf#L6) | The NCC Hub object. |  |
| [producer_vpc_network_spoke](outputs.tf#L11) | All producer network vpc spoke objects. |  |
| [router_appliance_spokes](outputs.tf#L16) | All router appliance spoke objects. |  |
| [spokes](outputs.tf#L21) | All spoke objects prefixed with the type of spoke (vpc, hybrid, appliance). |  |
| [vpc_spokes](outputs.tf#L43) | All vpc spoke objects. |  |
<!-- END TFDOC -->
# Usage

This example demonstrates how to use the module to create an NCC hub with three spokes: a VPN spoke, a VLAN spoke, and an Interconnect spoke.

```terraform
module "net-ncc" {
    source     = "./modules/net-ncc"
    project_id = "gcp-project-id"
    hub_name   = "hub-name"
    description = "My NCC Hub"
    spokes = [
        {
            name        = "spoke-vpn-01"
            type        = "VPN"
            description = "VPN Spoke"
            linked_vpn_tunnels = [
                "projects/gcp-project-id/regions/us-central1/vpnTunnels/tunnel-01",
                "projects/gcp-project-id/regions/us-central1/vpnTunnels/tunnel-02"
            ]
        },
        {
            name = "spoke-vlan-01"
            type = "VLAN"
            description = "VLAN Spoke"
            linked_interconnect_attachments = [
                "projects/gcp-project-id/regions/us-central1/interconnectAttachments/attachment-01",
                "projects/gcp-project-id/regions/us-central1/interconnectAttachments/attachment-02"
            ]
        },
        {
            name = "spoke-interconnect-01"
            type = "INTERCONNECT"
            description = "Interconnect Spoke"
            linked_interconnect_attachments = [
                "projects/gcp-project-id/regions/us-central1/interconnectAttachments/attachment-03",
                "projects/gcp-project-id/regions/us-central1/interconnectAttachments/attachment-04"
            ]
        }
    ]
}