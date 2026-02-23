# DNS Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module manages Google Cloud DNS resources: policies, managed zones, and record sets. It supports creating inbound/outbound forwarding policies, public and private DNS zones (with DNSSEC, forwarding, peering, and private‐visibility settings), and arbitrary record sets with optional routing (weighted/geo).

# Feature
- **DNS Policies**: define forwarding, logging, and network attachments.  
- **Managed Zones**: declare public or private zones with DNSSEC, forwarding, and peering.  
- **Record Sets**: create A/AAAA/CNAME/TXT/etc records with TTL and optional weighted or geo routing.  
- **Import Existing Zones**: import zones via data source for reference in record sets.  
- **Flexible Naming**: optional `resource_prefix` and `join_separator` to standardize resource IDs.  
- **Network Lookup**: map named networks to their self‐links for private zones and policies.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [project_id](variables.tf#L43) | The project ID where DNS resources will be created. | <code>string</code> | ✓ |  |
| [data_dns_managed_zones](variables.tf#L1) | Map of imported DNS managed zones. | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |
| [default_labels](variables.tf#L7) | Default labels applied to all DNS resources. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [dns_managed_zones](variables.tf#L13) | Map of DNS managed zone definitions. | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |
| [dns_policies](variables.tf#L19) | Map of DNS policies. | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |
| [dns_record_sets](variables.tf#L25) | Map of DNS record sets. | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L31) | Separator used when joining resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [network_lookup](variables.tf#L37) | Lookup map for networks to bind DNS policies. | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L48) | Prefix to prepend to resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [dns_managed_zones](outputs.tf#L1) | Map of created DNS managed zones. |  |
| [dns_managed_zones_map](outputs.tf#L15) | Map of created and imported DNS managed zones. |  |
| [dns_policies](outputs.tf#L37) | Map of created DNS policies. |  |
| [dns_policies_ids](outputs.tf#L49) | Map of DNS policy names to their IDs. |  |
| [dns_record_sets](outputs.tf#L56) | Map of created DNS record sets. |  |
| [name_servers](outputs.tf#L70) | Map of zone names to list of name servers. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "dns" {
  source            = "git::ssh://git@gitlab.com/your-org/terraform-modules-multicloud.git//modules/gcp/network/dns?ref=v1.0.0"
  project_id        = "my-project"
  resource_prefix   = "demo"
  join_separator    = "-"
  default_labels    = { env = "prod" }

  network_lookup = {
    default = { self_link = "projects/my-project/global/networks/default" }
  }

  dns_policies = {
    forward-internal = {
      name                      = "forward-internal"
      description               = "Forward certain queries to custom servers"
      enable_inbound_forwarding = true
      enable_logging            = false
      alternative_name_server_config = {
        target_name_servers = [
          { ipv4_address = "8.8.8.8", forwarding_path = "default" }
        ]
      }
      networks = ["default"]
    }
  }

  data_dns_managed_zones = {
    ext-zone = { 
      name    = "external-zone"
      project = "other-project"
    }
  }

  dns_managed_zones = {
    public-zone = {
      name        = "public-zone"
      dns_name    = "example.com."
      description = "Public DNS zone for example.com"
      visibility  = "public"
      labels      = { team = "devops" }
      dnssec_config = {
        kind          = "dnssec#DnsKeySpec"
        non_existence = "NSEC"
        state         = "on"
        default_key_specs = []
      }
    }
    private-zone = {
      name        = "private-zone"
      dns_name    = "internal.example.com."
      description = "Private zone on VPC"
      visibility  = "private"
      private_visibility_config = {
        networks = [{ network_url = module.network.self_link }]
      }
    }
  }

  dns_record_sets = {
    www = {
      managed_zone = "public-zone"
      name         = "www"            # becomes "www.example.com."
      type         = "A"
      ttl          = 300
      rrdatas      = ["203.0.113.10"]
      routing_policy = {
        wrr = []
        geo = []
      }
    }
    internal = {
      managed_zone = "private-zone"
      name         = null             # defaults to zone DNS name
      type         = "A"
      ttl          = 60
      rrdatas      = ["10.0.0.5"]
    }
  }
}