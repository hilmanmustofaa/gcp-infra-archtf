# ============================================================================
# Plan Test: secret-manager user-managed replication + CMEK
# ============================================================================
# Government / data-residency scenario: pin replication to asia-southeast2
# with a customer-managed encryption key.
# ============================================================================

mock_provider "google" {}

variables {
  project_id     = "dummy-project"
  join_separator = "-"

  default_labels = {
    env     = "prod"
    project = "govt"
    owner   = "infra-team"
  }
}

run "plan_user_managed_replication" {
  command = plan

  variables {
    secrets = {
      cert = {
        secret_id = "tls-cert"
        replication = {
          user_managed_replicas = [
            {
              location     = "asia-southeast2"
              kms_key_name = "projects/dummy-project/locations/asia-southeast2/keyRings/sm/cryptoKeys/sm-key"
            }
          ]
        }
      }
    }
  }

  assert {
    condition     = google_secret_manager_secret.secrets["cert"].replication[0].user_managed[0].replicas[0].location == "asia-southeast2"
    error_message = "User-managed replica must be pinned to asia-southeast2."
  }

  assert {
    condition     = google_secret_manager_secret.secrets["cert"].replication[0].user_managed[0].replicas[0].customer_managed_encryption[0].kms_key_name == "projects/dummy-project/locations/asia-southeast2/keyRings/sm/cryptoKeys/sm-key"
    error_message = "CMEK must be applied to the user-managed replica."
  }
}
