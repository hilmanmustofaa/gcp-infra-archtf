# Pub/Sub Topic Module

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

Creates and governs [Cloud Pub/Sub](https://cloud.google.com/pubsub/docs) topics and subscriptions from a single map-driven interface: CMEK, message retention, push/pull delivery, dead-letter policies, additive IAM, and mandatory FinOps labels.

It is the canonical Pub/Sub destination for the `logging-sink` module (real-time log fan-out) and the messaging backbone for event-driven workloads across engagements.

---

## Features

✅ **Map-driven topics & subscriptions** — create any number from the `topics` / `subscriptions` maps.

✅ **CMEK** — per-topic `kms_key_name` for banking/govt encryption requirements.

✅ **Subscription delivery** — pull (default) or push (`push_endpoint`), with `ack_deadline_seconds`, retention, `filter`, and expiration.

✅ **Dead-letter** — `dead_letter_topic` + `max_delivery_attempts` (enforced together via cross-field validation).

✅ **Additive IAM** — topic (`pubsub.publisher`) and subscription (`pubsub.subscriber`) members via `*_iam_member` (non-clobbering).

✅ **Topic resolution** — a subscription's `topic` accepts a logical topic key in this module or a literal topic id.

✅ **FinOps labels** — `env` / `project` / `owner` enforced + module labels on every topic and subscription.

---

## Security & Compliance Notes

- **CMEK + residency:** set `kms_key_name` (region-matched) for government/banking workloads; topics inherit the project's location policy.
- **Least privilege:** grant `roles/pubsub.publisher` / `roles/pubsub.subscriber` to specific service accounts via `iam_members`, not project-level roles.
- **Reliability:** configure a `dead_letter_topic` + `max_delivery_attempts` so poison messages don't block subscriptions; pair with an alert on the DLQ's `num_undelivered_messages`.

---

## Example Usage

```hcl
module "pubsub" {
  source = "../../modules/pubsub-topic"

  project_id      = var.project_id
  resource_prefix = "prod"

  default_labels = {
    env     = "prod"
    project = "events"
    owner   = "platform-team"
  }

  topics = {
    events = { name = "app-events" }
    dlq    = { name = "app-events-dlq" }
  }

  subscriptions = {
    worker = {
      name                  = "app-events-worker"
      topic                 = "events"
      ack_deadline_seconds  = 30
      dead_letter_topic     = "projects/${var.project_id}/topics/prod-app-events-dlq"
      max_delivery_attempts = 5
    }
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

---

## Testing

```bash
terraform -chdir=modules/pubsub-topic test -no-color
```

Scenarios:

* `plan_basic` — name prefixing, FinOps labels, topic/subscription IAM; plus CMEK + push + dead-letter
* `plan_negative` — missing FinOps labels, incomplete dead-letter config (topic without max attempts)

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [default_labels](variables.tf#L18) | Default labels applied to all topics. Must include 'env', 'project', and 'owner' for FinOps governance. | <code>map&#40;string&#41;</code> | ✓ |  |
| [project_id](variables.tf#L1) | The project ID to create Pub/Sub resources in. | <code>string</code> | ✓ |  |
| [join_separator](variables.tf#L12) | Separator used when joining prefix with resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L6) | Optional prefix applied to topic/subscription names. | <code>string</code> |  | <code>null</code> |
| [subscriptions](variables.tf#L49) | Map of Pub/Sub subscriptions to create, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  name  &#61; string&#10;  topic &#61; string &#35; a topic logical key in this module, or a full topic id&#10;&#10;&#10;  ack_deadline_seconds       &#61; optional&#40;number&#41;&#10;  message_retention_duration &#61; optional&#40;string&#41;&#10;  retain_acked_messages      &#61; optional&#40;bool&#41;&#10;  expiration_ttl             &#61; optional&#40;string&#41; &#35; &#34;&#34; &#61; never expire&#10;  filter                     &#61; optional&#40;string&#41;&#10;  push_endpoint &#61; optional&#40;string&#41;&#10;  dead_letter_topic     &#61; optional&#40;string&#41;&#10;  max_delivery_attempts &#61; optional&#40;number&#41;&#10;  iam_members &#61; optional&#40;map&#40;object&#40;&#123;&#10;    role   &#61; string&#10;    member &#61; string&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [topics](variables.tf#L32) | Map of Pub/Sub topics to create, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  name                       &#61; string&#10;  labels                     &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  kms_key_name               &#61; optional&#40;string&#41; &#35; CMEK&#10;  message_retention_duration &#61; optional&#40;string&#41; &#35; e.g. &#34;86400s&#34;&#10;  iam_members &#61; optional&#40;map&#40;object&#40;&#123;&#10;    role   &#61; string&#10;    member &#61; string&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [finops_labels](outputs.tf#L21) | FinOps label package for this module, to be merged with workspace-level defaults. |  |
| [subscription_ids](outputs.tf#L11) | Map of logical key => Pub/Sub subscription id. |  |
| [subscription_names](outputs.tf#L16) | Map of logical key => Pub/Sub subscription short name. |  |
| [topic_ids](outputs.tf#L1) | Map of logical key => Pub/Sub topic id (projects/.../topics/...). |  |
| [topic_names](outputs.tf#L6) | Map of logical key => Pub/Sub topic short name. |  |
<!-- END TFDOC -->
