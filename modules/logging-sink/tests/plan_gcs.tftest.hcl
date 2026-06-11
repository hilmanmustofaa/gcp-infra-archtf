# ============================================================================
# Plan Test: logging-sink -> GCS
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

run "plan_gcs" {
  command = plan

  variables {
    sinks = {
      archive = {
        name             = "logs-to-gcs"
        destination_type = "gcs"
        destination      = "central-log-archive"
      }
    }
  }

  assert {
    condition     = google_logging_project_sink.sinks["archive"].destination == "storage.googleapis.com/central-log-archive"
    error_message = "GCS sink destination URI must be storage.googleapis.com/<bucket>."
  }

  assert {
    condition     = google_storage_bucket_iam_member.gcs["archive"].role == "roles/storage.objectCreator"
    error_message = "Writer identity must be granted roles/storage.objectCreator on the bucket."
  }

  assert {
    condition     = google_storage_bucket_iam_member.gcs["archive"].bucket == "central-log-archive"
    error_message = "GCS grant must target the configured bucket."
  }
}
