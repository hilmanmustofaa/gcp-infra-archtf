# Cloud Monitoring Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Features](#features)
- [Security & Compliance Notes](#security-compliance-notes)
- [Example Usage](#example-usage)
- [Testing](#testing)
- [Variables](#variables)
- [Outputs](#outputs)
<!-- END TOC -->

## Description

This module provisions [Cloud Monitoring](https://cloud.google.com/monitoring) observability resources from a single, generic, map-driven interface:

- **Notification channels** — email, PagerDuty, Slack, Pub/Sub, SMS, etc.
- **Alert policies** — threshold and metric-absence conditions, with documentation and channel wiring.
- **Uptime checks** — HTTP(S) / TCP availability probes from Google's global checkers.

The schema is intentionally **generic rather than opinionated** — you define the exact conditions, filters, and thresholds. This keeps the module reusable across very different client SLAs (banking transaction latency, oil & gas uptime SLAs, government availability) without baking in one team's assumptions.

---

## Features

✅ **Generic alert policies** — full control of `conditions` (threshold or absence), `combiner`, `documentation`, and channels.

✅ **Channel reference resolution** — `alert_policies[].notification_channels` accepts either a logical key from `notification_channels` (resolved to the created channel id) or a literal channel id.

✅ **Uptime checks** — HTTP(S) or TCP, with monitored-resource targeting and region selection.

✅ **FinOps labels** — `env` / `project` / `owner` enforced and injected as `user_labels` on alert policies and notification channels.

✅ **Input validation** — combiner enum, exactly-one-condition-type, exactly-one-uptime-check-type.

---

## Security & Compliance Notes

- **Oil & Gas (uptime SLA):** model SAP / plant-control availability with `uptime_checks` + an absence alert (`condition_absent`) so a silent outage still pages.
- **Banking:** route security-relevant alerts to a monitored channel and reference the rotation/audit topics from the `secret-manager` and `logging-sink` modules.
- **Note:** Cloud Monitoring **uptime checks do not support user_labels**, so FinOps labels are applied to alert policies and notification channels only.

---

## Example Usage

```hcl
module "monitoring" {
  source = "../../modules/monitoring"

  project_id = var.project_id

  default_labels = {
    env     = "prod"
    project = "platform"
    owner   = "sre-team"
  }

  notification_channels = {
    email = {
      display_name = "SRE Email"
      type         = "email"
      labels       = { email_address = "sre@example.com" }
    }
  }

  alert_policies = {
    cpu = {
      display_name          = "High CPU utilization"
      notification_channels = ["email"]
      conditions = [{
        display_name = "CPU > 80% for 5m"
        condition_threshold = {
          filter           = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
          comparison       = "COMPARISON_GT"
          threshold_value  = 0.8
          duration         = "300s"
          alignment_period = "60s"
        }
      }]
    }
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example with an uptime check.

---

## Testing

```bash
terraform -chdir=modules/monitoring test -no-color
```

Scenarios:

* `plan_basic_alert` — alert policy, channel reference, FinOps user_labels
* `plan_uptime_check` — HTTP uptime check config
* `plan_notification_channel` — channel config + user_labels merge
* `plan_negative` — bad combiner, condition-without-type, uptime with both check types

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [default_labels](variables.tf#L6) | Default labels applied to alert policies and notification channels (as user_labels). Must include 'env', 'project', and 'owner' for FinOps governance. | <code>map&#40;string&#41;</code> | ✓ |  |
| [project_id](variables.tf#L1) | The project ID to deploy monitoring resources into. | <code>string</code> | ✓ |  |
| [alert_policies](variables.tf#L34) | Map of alert policies, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  display_name &#61; string&#10;  combiner     &#61; optional&#40;string, &#34;OR&#34;&#41;&#10;  enabled      &#61; optional&#40;bool, true&#41;&#10;  notification_channels &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;&#10;&#10;  documentation &#61; optional&#40;object&#40;&#123;&#10;    content   &#61; string&#10;    mime_type &#61; optional&#40;string, &#34;text&#47;markdown&#34;&#41;&#10;    subject   &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  user_labels &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;&#10;&#10;  conditions &#61; list&#40;object&#40;&#123;&#10;    display_name &#61; string&#10;    condition_threshold &#61; optional&#40;object&#40;&#123;&#10;      filter               &#61; string&#10;      comparison           &#61; string&#10;      threshold_value      &#61; optional&#40;number&#41;&#10;      duration             &#61; string&#10;      alignment_period     &#61; optional&#40;string&#41;&#10;      per_series_aligner   &#61; optional&#40;string&#41;&#10;      cross_series_reducer &#61; optional&#40;string&#41;&#10;      group_by_fields      &#61; optional&#40;list&#40;string&#41;&#41;&#10;      trigger_count        &#61; optional&#40;number&#41;&#10;    &#125;&#41;&#41;&#10;    condition_absent &#61; optional&#40;object&#40;&#123;&#10;      filter   &#61; string&#10;      duration &#61; string&#10;    &#125;&#41;&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [notification_channels](variables.tf#L20) | Map of notification channels, keyed by a logical name (referenced from alert_policies.notification_channels). | <code title="map&#40;object&#40;&#123;&#10;  display_name &#61; string&#10;  type         &#61; string                    &#35; e.g. &#34;email&#34;, &#34;pubsub&#34;, &#34;slack&#34;, &#34;sms&#34;&#10;  labels       &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41; &#35; channel config, e.g. &#123; email_address &#61; &#34;...&#34; &#125;&#10;  description  &#61; optional&#40;string&#41;&#10;  enabled      &#61; optional&#40;bool, true&#41;&#10;  user_labels  &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [uptime_checks](variables.tf#L94) | Map of uptime check configurations, keyed by a logical name. Uptime checks do not support user_labels. | <code title="map&#40;object&#40;&#123;&#10;  display_name &#61; string&#10;  timeout      &#61; optional&#40;string, &#34;10s&#34;&#41;&#10;  period       &#61; optional&#40;string, &#34;60s&#34;&#41;&#10;&#10;&#10;  monitored_resource &#61; object&#40;&#123;&#10;    type   &#61; string      &#35; e.g. &#34;uptime_url&#34;&#10;    labels &#61; map&#40;string&#41; &#35; e.g. &#123; host &#61; &#34;example.com&#34;, project_id &#61; &#34;...&#34; &#125;&#10;  &#125;&#41;&#10;&#10;&#10;  http_check &#61; optional&#40;object&#40;&#123;&#10;    path           &#61; optional&#40;string, &#34;&#47;&#34;&#41;&#10;    port           &#61; optional&#40;number&#41;&#10;    use_ssl        &#61; optional&#40;bool, true&#41;&#10;    validate_ssl   &#61; optional&#40;bool, true&#41;&#10;    request_method &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  tcp_check &#61; optional&#40;object&#40;&#123;&#10;    port &#61; number&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  selected_regions &#61; optional&#40;list&#40;string&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [alert_policy_ids](outputs.tf#L8) | Map of logical key => alert policy id (name). |  |
| [finops_labels](outputs.tf#L22) | FinOps label package for this module, to be merged with workspace-level defaults. |  |
| [notification_channel_ids](outputs.tf#L1) | Map of logical key => notification channel id. |  |
| [uptime_check_ids](outputs.tf#L15) | Map of logical key => uptime check config id. |  |
<!-- END TFDOC -->
