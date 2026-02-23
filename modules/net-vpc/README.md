# VPC Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description  
This module manages Google Cloud VPC networking building blocks: VPC networks, subnetworks (with secondary ranges & logging), static & policy-based routes, and data lookups for existing networks/subnets. It provides a consistent, parameterized way to declare your network topology and routing policies.

# Feature  
- **Multiple VPCs & Subnets**: create any number of custom networks & subnetworks with fine-grained settings (CIDR, IPv6, private Google access, secondary ranges).  
- **Data Sources**: reference existing networks or subnetworks via `data_compute_networks` and `data_compute_subnetworks`.  
- **Routing**: define both classic `google_compute_route` and advanced `policy-based routes` on Cloud Network Connectivity.  
- **Logging & Policies**: enable VPC flow logs on subnetworks and control firewall policy enforcement order.  
- **Flexible Naming**: support `resource_prefix` and `join_separator` for consistent naming conventions.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_routes](variables.tf#L1) | Map of route configurations. | <code title="map&#40;object&#40;&#123;&#10;  name                        &#61; string&#10;  network                     &#61; string&#10;  dest_range                  &#61; string&#10;  description                 &#61; optional&#40;string&#41;&#10;  priority                    &#61; optional&#40;number, 1000&#41;&#10;  tags                        &#61; optional&#40;list&#40;string&#41;&#41;&#10;  next_hop_gateway            &#61; optional&#40;string&#41;&#10;  next_hop_ip                 &#61; optional&#40;string&#41;&#10;  next_hop_instance_self_link &#61; optional&#40;string&#41;&#10;  next_hop_instance_zone      &#61; optional&#40;string&#41;&#10;  next_hop_ilb_self_link      &#61; optional&#40;string&#41;&#10;  project                     &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [networks](variables.tf#L37) | Map of VPC network configurations. | <code title="map&#40;object&#40;&#123;&#10;  project                           &#61; string&#10;  name                              &#61; string&#10;  description                       &#61; optional&#40;string&#41;&#10;  auto_create_subnetworks           &#61; optional&#40;bool, false&#41;&#10;  routing_mode                      &#61; optional&#40;string, &#34;GLOBAL&#34;&#41;&#10;  mtu                               &#61; optional&#40;number, 1460&#41;&#10;  delete_default_routes_on_create   &#61; optional&#40;bool, false&#41;&#10;  firewall_policy_enforcement_order &#61; optional&#40;string&#41;&#10;  enable_ula_internal_ipv6          &#61; optional&#40;bool&#41;&#10;  internal_ipv6_range               &#61; optional&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [subnetworks](variables.tf#L83) | Map of subnet configurations. | <code title="map&#40;object&#40;&#123;&#10;  project                  &#61; string&#10;  name                     &#61; string&#10;  network                  &#61; string&#10;  description              &#61; optional&#40;string&#41;&#10;  ip_cidr_range            &#61; string&#10;  region                   &#61; string&#10;  purpose                  &#61; optional&#40;string&#41;&#10;  role                     &#61; optional&#40;string&#41;&#10;  private_ip_google_access &#61; optional&#40;bool, true&#41;&#10;  secondary_ip_range &#61; optional&#40;map&#40;object&#40;&#123;&#10;    range_name    &#61; string&#10;    ip_cidr_range &#61; string&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;  log_config &#61; optional&#40;object&#40;&#123;&#10;    aggregation_interval &#61; optional&#40;string&#41;&#10;    flow_sampling        &#61; optional&#40;number&#41;&#10;    metadata             &#61; optional&#40;string&#41;&#10;    metadata_fields      &#61; optional&#40;list&#40;string&#41;&#41;&#10;    filter_expr          &#61; optional&#40;string&#41;&#10;  &#125;&#41;, &#123;&#125;&#41;&#10;  stack_type                 &#61; optional&#40;string&#41;&#10;  ipv6_access_type           &#61; optional&#40;string&#41;&#10;  private_ipv6_google_access &#61; optional&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [data_compute_networks](variables.tf#L19) | Map of data sources for compute networks. | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |
| [data_compute_subnetworks](variables.tf#L25) | Map of data sources for compute subnetworks. | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L31) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [policy_based_routes](variables.tf#L53) | Map of policy-based route configurations. | <code title="map&#40;object&#40;&#123;&#10;  name                &#61; string&#10;  network             &#61; string&#10;  description         &#61; optional&#40;string&#41;&#10;  priority            &#61; optional&#40;number, 1000&#41;&#10;  use_default_routing &#61; optional&#40;bool, false&#41;&#10;  next_hop_ilb_ip     &#61; optional&#40;string&#41;&#10;  project             &#61; string&#10;  filter &#61; object&#40;&#123;&#10;    protocol_version &#61; optional&#40;string, &#34;IPV4&#34;&#41;&#10;    ip_protocol      &#61; string&#10;    dest_range       &#61; string&#10;    src_range        &#61; string&#10;  &#125;&#41;&#10;  target &#61; object&#40;&#123;&#10;    tags                    &#61; optional&#40;list&#40;string&#41;&#41;&#10;    interconnect_attachment &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L77) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [data_compute_subnetworks](outputs.tf#L1) | Fetched data subnetworks from shared VPCs. |  |
| [networks](outputs.tf#L6) | Network resources created. |  |
| [policy_routes](outputs.tf#L11) | Created policy-based routes. |  |
| [routes](outputs.tf#L16) | Created routes. |  |
| [subnetworks](outputs.tf#L21) | Subnetwork resources created. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "vpc" {
  source          = "git::ssh://git@gitlab.com/your-org/terraform-modules.git//modules/gcp/network/vpc?ref=v1.0.0"
  resource_prefix = "acme"
  join_separator  = "-"

  # 1) Create two VPCs
  networks = {
    default = {
      project                         = "my-project"
      name                            = "default"
      description                     = "Primary VPC"
      auto_create_subnetworks         = false
      routing_mode                    = "GLOBAL"
      mtu                             = 1460
      delete_default_routes_on_create = true
      firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      enable_ula_internal_ipv6        = false
      internal_ipv6_range             = null
    }
    backend = {
      project                 = "my-project"
      name                    = "backend"
      description             = "Backend services VPC"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
      mtu                     = 1440
    }
  }

  # 2) Define subnetworks with secondary ranges & logs
  subnetworks = {
    frontend = {
      project                    = "my-project"
      network                    = "default"
      name                       = "frontend-subnet"
      description                = "Public subnet"
      region                     = "us-central1"
      ip_cidr_range              = "10.0.1.0/24"
      private_ip_google_access   = true
      purpose                    = "PRIVATE"
      role                       = "ACTIVE"
      stack_type                 = "IPV4_ONLY"
      ipv6_access_type           = "INTERNAL"
      private_ipv6_google_access = false

      secondary_ip_range = [
        { range_name = "pods";     ip_cidr_range = "10.1.0.0/16" },
        { range_name = "services"; ip_cidr_range = "10.2.0.0/20" }
      ]

      log_config = {
        aggregation_interval = "INTERVAL_5_SEC"
        flow_sampling        = 0.5
        metadata             = "INCLUDE_ALL_METADATA"
        metadata_fields      = ["project_id","subnet_id"]
        filter_expr          = "severity>=ERROR"
      }
    }
  }

  # 3) Reference an existing VPC & subnet
  data_compute_networks = {
    existing_vpc = { name = "shared-vpc"; project = "shared-project" }
  }
  data_compute_subnetworks = {
    shared_subnet = { name   = "shared-subnet"
                      project = "shared-project"
                      region  = "us-central1" }
  }

  # 4) Create a simple route
  compute_routes = {
    default-internet = {
      name       = "default-internet"
      network    = "default"
      dest_range = "0.0.0.0/0"
      next_hop_gateway = "default-internet-gateway"
    }
  }

  # 5) Policy-based route example
  policy_based_routes = {
    isolate-backend = {
      name                = "iso-backend"
      project             = "my-project"
      network             = "backend"
      filter = {
        protocol_version = "IPV4"
        ip_protocol      = "TCP"
        dest_range       = "10.0.0.0/16"
        src_range        = "0.0.0.0/0"
      }
      use_default_routing = false
      next_hop_ilb_ip     = "10.0.100.5"
      target = {
        tags = ["backend-servers"]
      }
    }
  }
}
