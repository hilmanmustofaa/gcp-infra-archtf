# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-12

### Added

- **`gke-cluster`** — `deletion_protection` variable (default `true`); the cluster
  resource previously had no control over it, so clusters couldn't be
  terraform-destroyed.
- **All apply-able `examples/` blueprints are now real-apply verified on a live
  project** (apply → destroy, zero strays): secured-artifact-registry,
  hybrid-cloud-vpn, compute-tls-lb-armor, secured-data-tier, serverless-modern-app,
  gke-with-nodepools. (The two `organization` blueprints are validate-only.)

### Fixed

- **`gke-nodepool`** — set `initial_node_count` only with autoscaling and
  `node_count` only without (GCP rejects setting both).
- **`serverless-modern-app` / `gke-with-nodepools`** blueprints rewritten to match
  module schemas + real GCP requirements (VPC connector instance bounds, Secret
  Manager version for Cloud Run, Workload Identity for the GKE metadata server,
  Cloud SQL network-lookup key, deletion_protection, run-scoped names).

### Changed

- **Security scanning migrated from tfsec (EOL) to [Trivy](https://trivy.dev).**
  CI installs the Trivy CLI directly (pinned) and runs `trivy config` → SARIF →
  GitHub Security; `task security` runs `trivy config` (HIGH/CRITICAL, soft),
  with `task security:strict` to enforce. `trivy.yaml` + `.trivyignore` replace
  `tfsec.yaml`. Trivy surfaced one real HIGH (`GCP-0057`, GKE node-metadata
  exposure) that the previous tfsec config missed — left visible for triage.
  (The `aquasecurity/trivy-action` was dropped: it transitively pins the yanked
  `setup-trivy@v0.2.1` and fails to resolve.)

### Added

- **CI now validates the `examples/` blueprints** (`validate-examples` job in the
  gate). With strongly-typed modules, `terraform validate` catches blueprint
  input-shape drift, so examples can no longer silently rot.

### Changed

- **Strong-typed every loosely (`type = any`) module** surfaced by real
  apply-testing: `net-router`, `net-security-policy`, `net-lb` (all 8 vars),
  `net-vpc`, `dns`, `cloudsql-instance`. Full object schemas; omitted optionals
  default to null and nested blocks are guarded by `!= null` (was `length()`),
  so `terraform validate` catches input drift.

### Fixed

- **`net-vpn`** — dynamic (BGP/router) tunnels no longer set `local/remote_traffic_selector`
  (GCP rejects combining `router` with traffic selectors).
- **`compute-mig`** — null-safety: health-check `enable_logging` guard
  (`coalesce`, since `try()` returns null for a present-but-null field) and
  autoscaler `scale_down/in_control` (`try()` when scaling control is unset).
- **`cloudsql-instance`** — `random_password` `for_each` no longer filters on the
  (sensitive) password value, which made the set sensitive → "Invalid for_each".
- **`net-lb`** — hyphenated dotted forwarding-rule label values (GCP rejects `.`
  in label values), completing the v1.0.1 label fix.
- **Rewrote the stale `examples/` blueprints** (`compute-tls-lb-armor`,
  `secured-data-tier`) to match current module schemas — they were never valid
  (e.g. `rules`→`rule`, `http_health_check`→`health_check{protocol}`,
  KMS key-ring reference, GCS `SetStorageClass`, storage/AR CMEK service-agent
  grants). Apply-verified on a live project (compute-tls-lb-armor: 15 resources,
  clean prune).

## [1.0.1] - 2026-06-11

### Fixed

- **FinOps label values hyphenated across 7 more modules** — `artifact-registry`,
  `cloud-run-v2`, `cloudsql-instance`, `dns`, `gke-cluster`,
  `gke-autopilot-cluster`, `net-lb`. They emitted dotted values
  (e.g. `container.googleapis.com/Cluster`, `sqladmin.googleapis.com`) which GCP
  **rejects** as label values (`[a-z0-9_-]` only), causing **apply-time
  failures** on resources that carry the mandatory FinOps labels. Plan tests
  never caught this; surfaced by real e2e. Values now follow the repo convention
  (`container-googleapis-com--cluster`, `sqladmin-googleapis-com`).

### Added

- **`e2e/label-smoke`** scenario — real apply+destroy on a live project proving
  the label-value fix applies cleanly (verified on `artifact-registry`;
  `gcs` covered by the existing `log-export` e2e).

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

[1.1.0]: https://github.com/hilmanmustofaa/gcp-infra-archtf/releases/tag/v1.1.0
[1.0.1]: https://github.com/hilmanmustofaa/gcp-infra-archtf/releases/tag/v1.0.1
[1.0.0]: https://github.com/hilmanmustofaa/gcp-infra-archtf/releases/tag/v1.0.0
