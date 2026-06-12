# BigQuery Dataset Module

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

Creates and governs [BigQuery datasets](https://cloud.google.com/bigquery/docs/datasets) from a single map-driven interface: location, expirations, time-travel, optional CMEK, additive IAM, and mandatory FinOps labels.

It is the canonical BigQuery destination for the `logging-sink` module (centralized audit-trail export) and for analytics datasets across engagements.

---

## Features

✅ **Map-driven datasets** — create any number of datasets from one `datasets` map.

✅ **CMEK** — per-dataset `kms_key_name` (`default_encryption_configuration`) for banking/govt.

✅ **Expirations & time-travel** — `default_table_expiration_ms`, `default_partition_expiration_ms`, `max_time_travel_hours`.

✅ **Additive IAM** — `iam_members` (role → member) via `google_bigquery_dataset_iam_member` (doesn't clobber default access).

✅ **FinOps labels** — `env` / `project` / `owner` enforced + module labels on every dataset.

---

## Security & Compliance Notes

- **Banking (OJK) audit trail:** export `cloudaudit.googleapis.com` logs here via `logging-sink` (BigQuery destination); partitioned + retained for queryable audit history.
- **CMEK + residency:** set `kms_key_name` (region-matched) and `location = "asia-southeast2"` for government workloads.
- **Least privilege:** grant `roles/bigquery.dataViewer` to specific groups via `iam_members`, not broad principals.

---

## Example Usage

```hcl
module "bq" {
  source = "../../modules/bq-dataset"

  project_id = var.project_id

  default_labels = {
    env     = "prod"
    project = "audit"
    owner   = "security-team"
  }

  datasets = {
    audit = {
      dataset_id                      = "audit_logs"
      location                        = "asia-southeast2"
      default_partition_expiration_ms = 31536000000 # 365 days
      kms_key_name                    = "projects/${var.project_id}/locations/asia-southeast2/keyRings/bq/cryptoKeys/bq-key"
    }
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

---

## Testing

```bash
terraform -chdir=modules/bq-dataset test -no-color
```

Scenarios:

* `plan_basic` — dataset id prefixing, location, FinOps labels; plus CMEK + additive IAM
* `plan_negative` — missing FinOps labels, invalid (dashed) dataset_id

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [default_labels](variables.tf#L12) | Default labels applied to all datasets. Must include 'env', 'project', and 'owner' for FinOps governance. | <code>map&#40;string&#41;</code> | ✓ |  |
| [project_id](variables.tf#L1) | The project ID to create BigQuery datasets in. | <code>string</code> | ✓ |  |
| [datasets](variables.tf#L26) | Map of BigQuery datasets to create, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  dataset_id  &#61; string&#10;  description &#61; optional&#40;string&#41;&#10;  location    &#61; optional&#40;string, &#34;asia-southeast2&#34;&#41;&#10;&#10;&#10;  default_table_expiration_ms     &#61; optional&#40;number&#41;&#10;  default_partition_expiration_ms &#61; optional&#40;number&#41;&#10;  max_time_travel_hours           &#61; optional&#40;number&#41;&#10;  delete_contents_on_destroy      &#61; optional&#40;bool, false&#41;&#10;  kms_key_name &#61; optional&#40;string&#41;&#10;&#10;&#10;  labels &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  iam_members &#61; optional&#40;map&#40;object&#40;&#123;&#10;    role   &#61; string&#10;    member &#61; string&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L6) | Optional prefix applied to dataset IDs (joined with '_'). | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [dataset_ids](outputs.tf#L1) | Map of logical key => BigQuery dataset_id. |  |
| [dataset_self_links](outputs.tf#L8) | Map of logical key => dataset self_link. |  |
| [finops_labels](outputs.tf#L15) | FinOps label package for this module, to be merged with workspace-level defaults. |  |
<!-- END TFDOC -->
