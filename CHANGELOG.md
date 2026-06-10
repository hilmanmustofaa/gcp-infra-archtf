# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-11

First stable release of the gcp-infra-archtf module library.

### Added

- **`monitoring` module** — generic, map-driven alert policies (threshold /
  absence), uptime checks (HTTP/TCP), and notification channels, with FinOps
  labels enforced as `user_labels` and input validation.
- **`logging-sink` module** — centralized log export to BigQuery, GCS, or
  Pub/Sub, with automatic writer-identity IAM grants on pre-existing
  destinations; supports exclusions, BigQuery partitioning, and cross-project
  sinks.
- **`secret-manager` module** — Secret Manager secrets with automatic or
  user-managed replication (per-replica CMEK), rotation policies, expiry,
  version aliases, and authoritative + additive IAM bindings.
- **`net-iap` module** — IAP tunnel and web-backend service IAM bindings, plus
  an opt-in, count-guarded OAuth brand/client.
- **`compute-vm`** — Windows first-class support: `windows_startup_script` and
  `windows_shutdown_script` mapped to the guest-agent metadata keys
  (`sysprep-specialize-script-ps1`, `windows-shutdown-script-ps1`).
- **`scaffold:module` Task** — generates the canonical module structure with
  FinOps `default_labels` validation baked in.
- **E2E scenarios** (`e2e/`) — real apply+destroy reference blueprints
  (`secure-secrets`, `log-export`) validated against a live project, run via
  `task e2e:toylabs` with an always-destroy strategy and `task e2e:destroy`
  fallback.

### Changed

- **`gcs`** — `autoclass` is now an object (`{ enabled, terminal_storage_class }`)
  with validation that autoclass and `lifecycle_rules` are mutually exclusive
  and `terminal_storage_class` is `NEARLINE` or `ARCHIVE`.
  **Breaking:** callers passing `autoclass = <bool>` must migrate to the object
  form (`autoclass = null` is unaffected).

### Fixed

- **`gcs`** — FinOps label values were dotted (`storage.googleapis.com`), which
  GCP rejects for label values; hyphenated to `storage-googleapis-com`. Buckets
  with FinOps labels now apply successfully.
- **`compute-vm`, `iam-service-accounts`** — aligned stale FinOps label test
  assertions with the hyphenated label convention.

[1.0.0]: https://github.com/hilmanmustofaa/gcp-infra-archtf/releases/tag/v1.0.0
