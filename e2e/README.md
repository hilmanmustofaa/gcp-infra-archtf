# E2E Scenarios (real apply)

This directory holds **real-apply** end-to-end scenarios that provision live
resources against a GCP project (default: `toylabs`, region `asia-southeast2`),
verify they apply cleanly, then destroy them. They double as **reference
blueprints** for composing the module library.

These are deliberately separate from the per-module `*.tftest.hcl` tests (which
are plan-only and run in CI without credentials). E2E scenarios are opt-in and
require Application Default Credentials with rights on the target project.

## Running

```bash
# All scenarios (apply + destroy each):
task e2e:toylabs

# A single scenario:
task e2e:toylabs SCENARIO=secure-secrets

# Different project:
E2E_PROJECT=my-sandbox task e2e:toylabs
```

## Destroy strategy

A clean teardown is a hard requirement — no orphaned billable resources.

1. **Always-destroy:** `task e2e:toylabs` runs `terraform apply` then **always**
   runs `terraform destroy` for each scenario, even if the apply failed
   partway (so partially-created resources are still removed).
2. **Run-scoped naming:** every scenario uses a `random_id` suffix, so repeated
   or concurrent runs never collide and strays are identifiable.
3. **Identifiable labels:** all labelable resources carry `env = e2e-toylabs`.
4. **Fallback cleanup:** if a run is interrupted (Ctrl-C, crash) and leaves
   local state, `task e2e:destroy` force-destroys every scenario's state.
5. **`force_destroy`** is enabled on buckets so they tear down even if a log
   object was written.

## Scenarios

| Scenario | Modules exercised | Notes |
|---|---|---|
| `secure-secrets` | `secret-manager`, `monitoring` | Secret with automatic replication + rotation topic (incl. the Secret Manager service-agent `pubsub.publisher` grant) and an email notification channel. |
| `log-export` | `gcs`, `logging-sink` | Bucket with Autoclass as a pre-existing destination + a GCS log sink with writer-identity IAM. Demonstrates the "destination must pre-exist" composition. |

Both scenarios have been validated end-to-end against `toylabs` (apply → destroy,
zero strays).

## Heavier blueprints (not auto-run)

Scenarios that create costly or slow resources — a secure web app
(`cloud-run-v2` + `net-iap` + `secret-manager` + `monitoring`), a GKE cluster,
or `net-iap` tunnel access to a real VM — belong here too but are intentionally
not part of the default `task e2e:toylabs` sweep. Add them as new subdirectories
following the same pattern (random suffix, `env=e2e-toylabs` labels,
`force_destroy`) and run them individually with `SCENARIO=<name>`.
