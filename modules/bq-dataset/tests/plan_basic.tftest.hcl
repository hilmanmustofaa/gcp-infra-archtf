mock_provider "google" {}

variables {
  project_id      = "dummy-project"
  resource_prefix = "demo"
  default_labels = {
    env     = "test"
    project = "demo"
    owner   = "platform"
  }
}

run "plan_basic" {
  command = plan

  variables {
    datasets = {
      audit = {
        dataset_id  = "audit_logs"
        description = "Audit log sink dataset"
        location    = "asia-southeast2"
      }
    }
  }

  assert {
    condition     = google_bigquery_dataset.datasets["audit"].dataset_id == "demo_audit_logs"
    error_message = "dataset_id must be prefixed with the (underscore-normalized) resource_prefix."
  }

  assert {
    condition     = google_bigquery_dataset.datasets["audit"].location == "asia-southeast2"
    error_message = "location must be wired."
  }

  assert {
    condition     = google_bigquery_dataset.datasets["audit"].labels["tf_module"] == "bq-dataset"
    error_message = "Dataset must carry the tf_module FinOps label."
  }

  assert {
    condition     = google_bigquery_dataset.datasets["audit"].labels["env"] == "test"
    error_message = "Dataset must carry the env default label."
  }
}

run "plan_with_cmek_and_iam" {
  command = plan

  variables {
    datasets = {
      secure = {
        dataset_id   = "secure_ds"
        kms_key_name = "projects/dummy-project/locations/asia-southeast2/keyRings/bq/cryptoKeys/bq-key"
        iam_members = {
          analyst = {
            role   = "roles/bigquery.dataViewer"
            member = "group:analysts@example.com"
          }
        }
      }
    }
  }

  assert {
    condition     = google_bigquery_dataset.datasets["secure"].default_encryption_configuration[0].kms_key_name == "projects/dummy-project/locations/asia-southeast2/keyRings/bq/cryptoKeys/bq-key"
    error_message = "CMEK key must be wired into default_encryption_configuration."
  }

  assert {
    condition     = google_bigquery_dataset_iam_member.members["secure/analyst"].role == "roles/bigquery.dataViewer"
    error_message = "IAM member must be created with the configured role."
  }
}
