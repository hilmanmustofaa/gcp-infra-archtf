# DNS Response Policy Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module creates and manages Cloud DNS Response Policies and their rules. It can either create a new response policy or attach rules to an existing one. Rules may be defined inline or imported from an external “factory” YAML/JSON file. Supports network and GKE‐cluster attachments, custom DNS behaviours (bypass, nxdomain, etc.), and local data overrides (A, CNAME, TXT records).

# Feature
- **Flexible Policy Creation**: create new or reuse existing response policies via `policy_create`.  
- **Factory Rules**: load rule definitions from an external YAML/JSON file (`factories_config.rules`) for DRY reuse.  
- **Inline Rules**: define additional rules via `rules` map with DNS name, behaviour, and optional local_data records.  
- **Network & GKE Attachments**: bind policies to VPC networks and GKE clusters for per‐network resolution control.  
- **Local Data Overrides**: inject local DNS records (A, CNAME, TXT, etc.) with custom TTLs.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [name](variables.tf#L24) | Policy name. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L43) | Project id for the zone. | <code>string</code> | ✓ |  |
| [clusters](variables.tf#L1) | Map of GKE clusters to which this policy is applied in name => id format. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [description](variables.tf#L8) | Policy description. | <code>string</code> |  | <code>&#34;Terraform managed.&#34;</code> |
| [factories_config](variables.tf#L14) | Path to folder containing rules data files for the optional factory. | <code title="object&#40;&#123;&#10;  rules &#61; optional&#40;string&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L54) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [networks](variables.tf#L29) | Map of VPC self links to which this policy is applied in name => self link format. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [policy_create](variables.tf#L36) | Set to false to use the existing policy matching name and only manage rules. | <code>bool</code> |  | <code>true</code> |
| [resource_prefix](variables.tf#L48) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |
| [rules](variables.tf#L60) | Map of policy rules in name => rule format. Local data takes precedence over behavior and is in the form record type => attributes. | <code title="map&#40;object&#40;&#123;&#10;  dns_name &#61; string&#10;  behavior &#61; optional&#40;string, &#34;bypassResponsePolicy&#34;&#41;&#10;  local_data &#61; optional&#40;map&#40;object&#40;&#123;&#10;    ttl     &#61; optional&#40;number&#41;&#10;    rrdatas &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [id](outputs.tf#L1) | Fully qualified policy id. |  |
| [name](outputs.tf#L6) | Policy name. |  |
| [policy](outputs.tf#L11) | Policy resource. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "dns_response_policy" {
  source          = "git::ssh://git@gitlab.com/your-org/terraform-modules-multicloud.git//modules/gcp/network/dns_response_policy?ref=v1.0.0"
  project_id      = "my-project"
  name            = "custom-response-policy"
  description     = "Policy to override corporate DNS"
  policy_create   = true

  factories_config = {
    rules = "${path.module}/factory_rules.yaml"
  }

  networks = [
    "projects/my-project/global/networks/default",
    "projects/my-project/global/networks/shared-vpc"
  ]

  clusters = [
    "projects/my-project/locations/us-central1/clusters/app-cluster"
  ]

  rules = {
    # Simple bypass rule
    bypass-google = {
      dns_name = "google.com."
      behavior = "bypassResponsePolicy"
    }

    # Inject a local A record
    local-internal = {
      dns_name = "internal.example.com."
      local_data = {
        "A" = {
          ttl     = 300
          rrdatas = ["10.0.0.5"]
        }
      }
    }
  }
}
