# Cloud Armor Security Policy Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module manages Google Cloud Armor Security Policies, providing WAF and DDoS protection for your applications.

# Feature
- **Security Policies**: create and manage Cloud Armor security policies.
- **Rules**: define rules with various actions, priorities, and match conditions.
- **Rate Limiting**: configure rate limiting options for rules.
- **Redirection**: configure redirection options for rules.
- **Advanced Options**: configure advanced options like JSON parsing and log levels.
- **Adaptive Protection**: configure adaptive protection settings.
- **Flexible Naming**: support `resource_prefix` and `join_separator` for consistent naming conventions.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_security_policies](variables.tf#L1) | A map of security policy objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L8) | The separator to use when joining the prefix and the name. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L14) | A prefix for the resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [security_policies](outputs.tf#L1) | The created security policies. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "security_policy" {
  source = "./modules/net-security-policy"

  compute_security_policies = {
    "my-security-policy" = {
      name        = "my-security-policy"
      description = "My Cloud Armor Security Policy"
      project     = "my-project"
      type        = "CLOUD_ARMOR"
      rule = [
        {
          action   = "allow"
          priority = 1000
          description = "Allow traffic from specific IP range"
          match = {
            versioned_expr = "SRC_IPS_V1"
            config = {
              src_ip_ranges = ["192.168.1.0/24"]
            }
          }
        },
        {
          action   = "deny-403"
          priority = 2147483647 # Default rule
          description = "Default deny rule"
          match = {
            versioned_expr = "SRC_IPS_V1"
            config = {
              src_ip_ranges = ["*"]
            }
          }
        }
      ]
    }
  }
}
