# Cloud NAT Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Examples](#examples)
- [Features](#features)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description

This module manages the creation of Cloud NAT resources, supporting both Public and Private NAT (Inter-VPC NAT).

## Examples

- [Basic Public NAT](examples/basic)
- [Private NAT](examples/private)

## Features

- Public and Private NAT support
- Configurable IP allocation (Auto/Manual)
- Custom logging configuration
- Advanced rule configuration for Private NAT
- **Auto- or Static-NAT IPs**: choose `AUTO_ONLY` to let GCP assign IPs, or `MANUAL_ONLY` to use your own via `nat_ips`.
- **Subnet Scoping**: NAT all subnets in a region, or list specific subnetworks with per-subnet IP-range controls.
- **Port Allocation Controls**: tune `min_ports_per_vm`, `max_ports_per_vm`, and endpoint independence.
- **Logging & Monitoring**: enable Cloud NAT logging with custom filters.
- **Custom Rules**: define numbered NAT rules (matching expressions + actions) for fine-grained traffic control.
- **Endpoint Types**: scope NAT to private ranges, public, or all endpoints.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_router_nats](variables.tf#L1) | Map of Cloud NAT configurations to create. | <code title="map&#40;object&#40;&#123;&#10;  name                               &#61; string&#10;  project                            &#61; string&#10;  region                             &#61; string&#10;  router                             &#61; string&#10;  type                               &#61; optional&#40;string, &#34;PUBLIC&#34;&#41;&#10;  nat_ip_allocate_option             &#61; string&#10;  nat_ips                            &#61; list&#40;string&#41;&#10;  source_subnetwork_ip_ranges_to_nat &#61; string&#10;&#10;&#10;  subnetwork &#61; optional&#40;map&#40;object&#40;&#123;&#10;    name                     &#61; string&#10;    source_ip_ranges_to_nat  &#61; list&#40;string&#41;&#10;    secondary_ip_range_names &#61; optional&#40;list&#40;string&#41;&#41;&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;&#10;&#10;  min_ports_per_vm                    &#61; optional&#40;number&#41;&#10;  max_ports_per_vm                    &#61; optional&#40;number&#41;&#10;  enable_dynamic_port_allocation      &#61; optional&#40;bool&#41;&#10;  enable_endpoint_independent_mapping &#61; optional&#40;bool&#41;&#10;&#10;&#10;  udp_idle_timeout_sec             &#61; optional&#40;number&#41;&#10;  icmp_idle_timeout_sec            &#61; optional&#40;number&#41;&#10;  tcp_established_idle_timeout_sec &#61; optional&#40;number&#41;&#10;  tcp_transitory_idle_timeout_sec  &#61; optional&#40;number&#41;&#10;  tcp_time_wait_timeout_sec        &#61; optional&#40;number&#41;&#10;&#10;&#10;  log_config &#61; object&#40;&#123;&#10;    enable &#61; bool&#10;    filter &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#10;&#10;&#10;  endpoint_types &#61; optional&#40;list&#40;string&#41;&#41;&#10;&#10;&#10;  rules &#61; optional&#40;map&#40;object&#40;&#123;&#10;    description &#61; optional&#40;string&#41;&#10;    match       &#61; string&#10;    action &#61; object&#40;&#123;&#10;      source_nat_active_ips &#61; optional&#40;list&#40;string&#41;&#41;&#10;      source_nat_drain_ips  &#61; optional&#40;list&#40;string&#41;&#41;&#10;    &#125;&#41;&#10;  &#125;&#41;&#41;&#41; &#35; Key must be a numeric string &#40;e.g. &#34;100&#34;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [nat_ip_lookup](variables.tf#L48) | Map of NAT IP names to their static self_link addresses. | <code title="map&#40;object&#40;&#123;&#10;  self_link &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [network_lookup](variables.tf#L55) | Map of subnet names to their self_link references. | <code title="map&#40;object&#40;&#123;&#10;  self_link &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [router_lookup](variables.tf#L68) | Map of router names to their attributes (must include 'name'). | <code title="map&#40;object&#40;&#123;&#10;  name &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [resource_prefix](variables.tf#L62) | Prefix to be used for resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [nat_ids](outputs.tf#L1) | Map of NAT IDs keyed by name. |  |
| [nat_names](outputs.tf#L8) | Map of NAT names keyed by name. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "cloudnat" {
  source = "git::ssh://git@gitlab.com/your-org/terraform-modules.git//modules/gcp/network/cloudnat?ref=v1.0.0"

  # 1) Attach to an existing Cloud Router
  router_lookup = {
    default = { name = "router-default" }
  }

  # 2) Auto-allocate NAT IPs, cover all subnets
  compute_router_nats = {
    nat-default = {
      project                             = "my-project"
      region                              = "us-central1"
      router                              = "default"
      nat_ip_allocate_option              = "AUTO_ONLY"
      nat_ips                             = []
      source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
      min_ports_per_vm                    = 64
      enable_dynamic_port_allocation      = true
      enable_endpoint_independent_mapping = true
      log_config = {
        enable = true
        filter = "ALL"
      }
      endpoint_types = ["PRIVATE_RANGES_ONLY"]
    }
  }
}

# 3) Or, to supply your own NAT IPs & per-subnet rules:

data "google_compute_subnetwork" "subnet-a" {
  name    = "subnet-a"
  region  = "us-central1"
  project = "my-project"
}

resource "google_compute_address" "nat_ip" {
  name   = "nat-ip-1"
  region = "us-central1"
}

module "cloudnat_manual" {
  source         = ".../modules/gcp/network/cloudnat"
  router_lookup  = { router1 = { name = "router-default" } }
  nat_ip_lookup  = { ip1 = google_compute_address.nat_ip.self_link }
  network_lookup = { subnetA = data.google_compute_subnetwork.subnet-a.self_link }

  compute_router_nats = {
    nat1 = {
      project                            = "my-project"
      region                             = "us-central1"
      router                             = "router1"
      nat_ip_allocate_option             = "MANUAL_ONLY"
      nat_ips                            = ["ip1"]
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
      subnetwork = [
        {
          name                     = "subnetA"
          source_ip_ranges_to_nat  = ["ALL_PRIMARY_IP_RANGES"]
          secondary_ip_range_names = []
        }
      ]
      min_ports_per_vm                    = 128
      enable_dynamic_port_allocation      = false
      enable_endpoint_independent_mapping = true
      log_config = {
        enable = true
        filter = "ERRORS_ONLY"
      }
      rules = {
        100 = {
          description = "Override default for subnetA"
          match       = "true"
          action = {
            source_nat_active_ips = []
            source_nat_drain_ips  = []
          }
        }
      }
    }
  }
}
```
