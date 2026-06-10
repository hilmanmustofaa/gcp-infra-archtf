# Logging Sink Module

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

This module creates [Cloud Logging sinks](https://cloud.google.com/logging/docs/export) that export logs to **BigQuery**, **Cloud Storage**, or **Pub/Sub**, and grants the sink's writer identity the minimal role required on the destination.

It is the backbone of centralized audit-trail export for banking (OJK) and long-retention log archival for government engagements.

> **Destinations must already exist.** This module is intentionally single-responsibility: it creates the sink and the writer-identity IAM grant only. Provision the BigQuery dataset / GCS bucket / Pub/Sub topic with their own modules (e.g. `gcs`) and pass the name in. This keeps modules composable and avoids duplicating destination logic.

> **No `default_labels`** — `google_logging_project_sink` has no labelable fields. FinOps labels live on the destination resources, which are managed by their own modules.

---

## Features

✅ **Three destination types** — `bigquery` | `gcs` | `pubsub`, selected per sink via `destination_type`. The full destination URI is built for you from the short resource name.

✅ **Writer-identity IAM** — automatically grants the sink's writer identity the right role on the destination (`bigquery.dataEditor` / `storage.objectCreator` / `pubsub.publisher`). Toggle with `grant_destination_permission`.

✅ **Exclusions** — per-sink exclusion filters to drop noisy logs before export (cost control).

✅ **BigQuery partitioning** — `use_partitioned_tables` for date-partitioned audit datasets.

✅ **Validation** — `destination_type` is constrained to the three supported types.

---

## Security & Compliance Notes

- **Banking (OJK audit trail):** export `cloudaudit.googleapis.com` logs to a partitioned BigQuery dataset for queryable, retained audit history.
- **Government (≥ 1 year retention):** export to a GCS bucket in `asia-southeast2` with a retention/lifecycle policy (configured on the bucket via the `gcs` module) — data residency stays in-region.
- **Cross-project sinks:** set `destination_project` to export into a dedicated, locked-down logging project (recommended for tamper resistance).

---

## Example Usage

```hcl
module "log_export" {
  source = "../../modules/logging-sink"

  project_id = var.project_id

  sinks = {
    audit_to_bq = {
      name             = "audit-to-bq"
      destination_type = "bigquery"
      destination      = "audit_logs" # pre-existing dataset
      filter           = "logName:\"cloudaudit.googleapis.com\""
    }
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

---

## Testing

```bash
terraform -chdir=modules/logging-sink test -no-color
```

Scenarios:

* `plan_bigquery` — BQ destination URI, partitioned tables, dataEditor grant
* `plan_gcs` — GCS destination URI, objectCreator grant
* `plan_pubsub` — Pub/Sub destination URI, publisher grant, exclusions
* `plan_negative` — invalid destination_type

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [project_id](variables.tf#L1) | The project ID that owns the log sinks. | <code>string</code> | ✓ |  |
| [sinks](variables.tf#L6) | Map of log sinks to create, keyed by a logical name. Destinations (BigQuery dataset, GCS bucket, Pub/Sub topic) must already exist. | <code title="map&#40;object&#40;&#123;&#10;  name             &#61; string&#10;  destination_type &#61; string &#35; bigquery &#124; gcs &#124; pubsub&#10;  destination      &#61; string &#35; short resource name: dataset_id &#124; bucket_name &#124; topic_name&#10;  destination_project &#61; optional&#40;string&#41;&#10;&#10;&#10;  filter      &#61; optional&#40;string&#41;&#10;  description &#61; optional&#40;string&#41;&#10;  disabled    &#61; optional&#40;bool, false&#41;&#10;  unique_writer_identity &#61; optional&#40;bool, true&#41;&#10;  use_partitioned_tables &#61; optional&#40;bool&#41;&#10;  grant_destination_permission &#61; optional&#40;bool, true&#41;&#10;&#10;&#10;  exclusions &#61; optional&#40;map&#40;object&#40;&#123;&#10;    filter      &#61; string&#10;    description &#61; optional&#40;string&#41;&#10;    disabled    &#61; optional&#40;bool, false&#41;&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [sink_destinations](outputs.tf#L8) | Map of logical key => fully-qualified sink destination URI. |  |
| [sink_ids](outputs.tf#L1) | Map of logical key => log sink id. |  |
| [writer_identities](outputs.tf#L13) | Map of logical key => sink writer identity (service account) to grant on the destination. |  |
<!-- END TFDOC -->
