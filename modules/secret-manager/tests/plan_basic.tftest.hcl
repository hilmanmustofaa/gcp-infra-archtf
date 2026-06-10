# ============================================================================
# Plan Test: secret-manager basic (automatic replication)
# ============================================================================

mock_provider "google" {}

variables {
  project_id      = "dummy-project"
  resource_prefix = "demo"
  join_separator  = "-"

  default_labels = {
    env     = "test"
    project = "demo"
    owner   = "platform"
  }
}

run "plan_basic" {
  command = plan

  variables {
    secrets = {
      api = {
        secret_id = "api-key"
        labels    = { tier = "app" }
        replication = {
          automatic = true
        }
        iam_bindings = {
          accessors = {
            role    = "roles/secretmanager.secretAccessor"
            members = ["serviceAccount:app@dummy-project.iam.gserviceaccount.com"]
          }
        }
      }
    }
  }

  # secret_id is prefixed and joined.
  assert {
    condition     = output.secret_ids["api"] == "demo-api-key"
    error_message = "secret_id must be prefixed with resource_prefix."
  }

  # FinOps + module labels merged onto the secret.
  assert {
    condition     = google_secret_manager_secret.secrets["api"].labels["tf_module"] == "secret-manager"
    error_message = "Secret must carry tf_module=secret-manager label."
  }

  assert {
    condition     = google_secret_manager_secret.secrets["api"].labels["env"] == "test"
    error_message = "Secret must carry the env default label."
  }

  # Automatic replication block present.
  assert {
    condition     = length(google_secret_manager_secret.secrets["api"].replication[0].auto) == 1
    error_message = "Automatic replication (auto block) must be configured."
  }

  # IAM binding wired to the secret.
  assert {
    condition     = google_secret_manager_secret_iam_binding.bindings["api/accessors"].role == "roles/secretmanager.secretAccessor"
    error_message = "IAM binding must use the secretAccessor role."
  }
}
