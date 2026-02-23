# Cloud Router Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module manages Google Cloud Routers.

# Feature
- **Multiple Routers**: create any number of routers.
- **BGP**: configure BGP for each router.
- **Flexible Naming**: support `resource_prefix` and `join_separator` for consistent naming conventions.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_routers](variables.tf#L1) | A map of router objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L8) | The separator to use when joining the prefix and the name. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L14) | A prefix for the resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [routers](outputs.tf#L1) | The created routers. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "router" {
  source = "./modules/net-router"

  compute_routers = {
    "my-router" = {
      name    = "my-router"
      network = "my-network"
      project = "my-project"
      region  = "us-central1"
      bgp = {
        asn = 64514
      }
    }
  }
}
```