# Firewall Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description  
This module manages Google Cloud firewall rules, supporting both ingress and egress policies. It lets you define allow/deny blocks, priorities, logging, and conditional prechecks, all in a consistent, reusable way.

# Feature  
- **Ingress & Egress**: define direction, source/destination ranges, tags, or service-account based rules.  
- **Allow & Deny Blocks**: granular control over protocols and ports for both allow and deny actions.  
- **Logging**: optional flow logs with metadata inclusion.  
- **Dynamic Preconditions**: prevents misconfiguration by requiring appropriate source/destination parameters based on direction.  
- **Flexible Network Lookup**: accept either self-link or logical name via `network_self_links` map.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_firewalls](variables.tf#L1) | Map of firewall rule configurations. | <code title="map&#40;object&#40;&#123;&#10;  project     &#61; string&#10;  name        &#61; string&#10;  network     &#61; string&#10;  description &#61; optional&#40;string, &#34;Managed by Terraform&#34;&#41;&#10;  direction   &#61; optional&#40;string, &#34;INGRESS&#34;&#41;&#10;  priority    &#61; optional&#40;number, 1000&#41;&#10;  disabled    &#61; optional&#40;bool, false&#41;&#10;&#10;&#10;  allow &#61; optional&#40;list&#40;object&#40;&#123;&#10;    protocol &#61; string&#10;    ports    &#61; optional&#40;list&#40;string&#41;&#41;&#10;  &#125;&#41;&#41;, &#91;&#93;&#41;&#10;&#10;&#10;  deny &#61; optional&#40;list&#40;object&#40;&#123;&#10;    protocol &#61; string&#10;    ports    &#61; optional&#40;list&#40;string&#41;&#41;&#10;  &#125;&#41;&#41;, &#91;&#93;&#41;&#10;&#10;&#10;  source_ranges           &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  destination_ranges      &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  source_tags             &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  target_tags             &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  source_service_accounts &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  target_service_accounts &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;&#10;&#10;  log_config &#61; optional&#40;object&#40;&#123;&#10;    metadata &#61; optional&#40;string&#41;&#10;  &#125;&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [join_separator](variables.tf#L59) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [network_self_links](variables.tf#L65) | Optional map of network name to its self_link (from resource or data). | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L71) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [firewall_rules](outputs.tf#L1) | Created firewall rules. |  |
| [firewall_rules_self_links](outputs.tf#L6) | Self links of created firewall rules. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "firewall" {
  source             = "git::ssh://git@gitlab.com/your-org/terraform-modules.git//modules/gcp/network/firewall?ref=v1.0.0"
  resource_prefix    = "acme"
  join_separator     = "-"
  network_self_links = {
    default = google_compute_network.network.default.self_link
  }

  compute_firewalls = {
    allow-http = {
      project           = "my-project"
      name              = "allow-http"
      network           = "default"
      direction         = "INGRESS"
      priority          = 1000
      disabled          = false

      allow = [
        { protocol = "tcp", ports = ["80"] }
      ]

      source_ranges = ["0.0.0.0/0"]

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }

    deny-all-egress = {
      project            = "my-project"
      name               = "deny-egress"
      network            = "default"
      direction          = "EGRESS"
      priority           = 1000
      disabled           = false

      deny = [
        { protocol = "all" }
      ]

      destination_ranges = ["0.0.0.0/0"]
    }
  }
}
