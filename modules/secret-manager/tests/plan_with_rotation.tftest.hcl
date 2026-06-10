# ============================================================================
# Plan Test: secret-manager with rotation policy + Pub/Sub topics
# ============================================================================

mock_provider "google" {}

variables {
  project_id      = "dummy-project"
  resource_prefix = "demo"
  join_separator  = "-"

  default_labels = {
    env     = "prod"
    project = "banking"
    owner   = "security-team"
  }
}

run "plan_with_rotation" {
  command = plan

  variables {
    secrets = {
      db = {
        secret_id = "db-password"
        replication = {
          automatic = true
        }
        rotation = {
          rotation_period    = "7776000s" # 90 days
          next_rotation_time = "2026-09-01T00:00:00Z"
        }
        topics = ["projects/dummy-project/topics/secret-rotation"]
      }
    }
  }

  assert {
    condition     = google_secret_manager_secret.secrets["db"].rotation[0].rotation_period == "7776000s"
    error_message = "Rotation period must be wired to the secret."
  }

  assert {
    condition     = google_secret_manager_secret.secrets["db"].topics[0].name == "projects/dummy-project/topics/secret-rotation"
    error_message = "Rotation topic must be configured on the secret."
  }
}
