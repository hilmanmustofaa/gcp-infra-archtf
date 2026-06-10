# Secret Manager Module

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

This module provisions and governs [Google Secret Manager](https://cloud.google.com/secret-manager) secrets through a single map-driven interface. It handles replication strategy (automatic or user-managed with per-replica CMEK), rotation policies with Pub/Sub notifications, expiry, version aliases, optional bootstrap secret values, and authoritative + additive IAM bindings — all with mandatory FinOps labels.

It is the canonical way to manage secrets across NTT Data client engagements, where Secret Manager is mandatory for banking (OJK) workloads and CMEK + data residency are required for government workloads.

---

## Features

✅ **Map-driven secrets** — create any number of secrets from a single `secrets` map.

✅ **Replication strategies** — `automatic` for simplicity, or `user_managed` replicas pinned to specific regions (e.g. `asia-southeast2`) with optional per-replica customer-managed encryption keys (CMEK).

✅ **Rotation policies** — `rotation_period` + `next_rotation_time`, validated to require at least one Pub/Sub topic (GCP constraint).

✅ **IAM, two modes** — authoritative `iam_bindings` (role → members) and additive `iam_members` (role → single member), both with the standard Secret Manager roles.

✅ **Expiry & aliases** — optional `ttl` / `expire_time` (mutually exclusive) and `version_aliases`.

✅ **Bootstrap values (optional)** — seed an initial secret version via `secret_data`; prefer managing material out-of-band.

✅ **FinOps labels** — enforces `env` / `project` / `owner` and injects standard module labels on every secret.

---

## Security & Compliance Notes

- **Banking (OJK POJK 11/2022):** Secret Manager is mandatory for credential storage. Combine with CMEK (`user_managed_replicas[].kms_key_name`) and route rotation events to a monitored Pub/Sub topic for audit.
- **Government (data residency):** use `replication.user_managed_replicas` pinned to `asia-southeast2` only — never `automatic` (which may replicate outside the region).
- **Keep secret material out of state where possible:** avoid `secret_data` for production secrets; write versions out-of-band (CI, gcloud, application). When `secret_data` is used, the value lands in Terraform state — store state encrypted.
- **Least privilege:** grant `roles/secretmanager.secretAccessor` to specific service accounts via `iam_bindings`, not broad principals.

---

## Example Usage

```hcl
module "secrets" {
  source = "../../modules/secret-manager"

  project_id      = var.project_id
  resource_prefix = "bank-prod"

  default_labels = {
    env     = "prod"
    project = "core-banking"
    owner   = "security-team"
  }

  secrets = {
    db_password = {
      secret_id = "db-password"
      replication = {
        user_managed_replicas = [
          {
            location     = "asia-southeast2"
            kms_key_name = "projects/${var.project_id}/locations/asia-southeast2/keyRings/sm/cryptoKeys/sm-key"
          }
        ]
      }
      rotation = {
        rotation_period    = "7776000s" # 90 days
        next_rotation_time = "2026-09-01T00:00:00Z"
      }
      topics = ["projects/${var.project_id}/topics/secret-rotation"]
      iam_bindings = {
        app = {
          role    = "roles/secretmanager.secretAccessor"
          members = ["serviceAccount:app@${var.project_id}.iam.gserviceaccount.com"]
        }
      }
    }
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

---

## Testing

```bash
terraform -chdir=modules/secret-manager test -no-color
```

Scenarios:

* `plan_basic` — automatic replication, label merge, prefix, IAM binding wiring
* `plan_with_rotation` — rotation period + Pub/Sub topic
* `plan_user_managed_replication` — region-pinned replica + CMEK
* `plan_negative` — replication none/both, rotation-without-topics, ttl+expire_time conflicts

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [default_labels](variables.tf#L18) | Default labels applied to all secrets. Must include 'env', 'project', and 'owner' for FinOps governance. | <code>map&#40;string&#41;</code> | ✓ |  |
| [project_id](variables.tf#L1) | The project ID to create secrets in. | <code>string</code> | ✓ |  |
| [join_separator](variables.tf#L12) | Separator used when joining prefix with resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L6) | Optional prefix applied to secret IDs. | <code>string</code> |  | <code>null</code> |
| [secrets](variables.tf#L32) | Map of Secret Manager secrets to create, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  secret_id   &#61; string&#10;  labels      &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  annotations &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  replication &#61; object&#40;&#123;&#10;    automatic &#61; optional&#40;bool, false&#41;&#10;    user_managed_replicas &#61; optional&#40;list&#40;object&#40;&#123;&#10;      location     &#61; string&#10;      kms_key_name &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#41;, &#91;&#93;&#41;&#10;  &#125;&#41;&#10;  rotation &#61; optional&#40;object&#40;&#123;&#10;    next_rotation_time &#61; optional&#40;string&#41;&#10;    rotation_period    &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;  topics &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  ttl         &#61; optional&#40;string&#41;&#10;  expire_time &#61; optional&#40;string&#41;&#10;&#10;&#10;  version_aliases &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  secret_data &#61; optional&#40;string&#41;&#10;  iam_bindings &#61; optional&#40;map&#40;object&#40;&#123;&#10;    role    &#61; string&#10;    members &#61; list&#40;string&#41;&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;  iam_members &#61; optional&#40;map&#40;object&#40;&#123;&#10;    role   &#61; string&#10;    member &#61; string&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [finops_labels](outputs.tf#L20) | FinOps label package for this module, to be merged with workspace-level defaults. |  |
| [secret_ids](outputs.tf#L1) | Map of logical key => secret_id (short ID) for each created secret. |  |
| [secret_names](outputs.tf#L8) | Map of logical key => fully-qualified secret resource name (projects/.../secrets/...). |  |
| [secrets](outputs.tf#L15) | Map of created secret resources. |  |
<!-- END TFDOC -->
