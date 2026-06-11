# ============================================================================
# Plan Test: logging-sink -> BigQuery (banking/govt audit trail)
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

run "plan_bigquery" {
  command = plan

  variables {
    sinks = {
      audit = {
        name                   = "audit-to-bq"
        destination_type       = "bigquery"
        destination            = "audit_logs"
        filter                 = "logName:\"cloudaudit.googleapis.com\""
        use_partitioned_tables = true
      }
    }
  }

  assert {
    condition     = google_logging_project_sink.sinks["audit"].destination == "bigquery.googleapis.com/projects/dummy-project/datasets/audit_logs"
    error_message = "BigQuery sink destination URI must be built from type + dataset."
  }

  assert {
    condition     = google_logging_project_sink.sinks["audit"].bigquery_options[0].use_partitioned_tables == true
    error_message = "use_partitioned_tables must be wired for BigQuery sinks."
  }

  assert {
    condition     = google_bigquery_dataset_iam_member.bq["audit"].role == "roles/bigquery.dataEditor"
    error_message = "Writer identity must be granted roles/bigquery.dataEditor on the dataset."
  }

  assert {
    condition     = google_bigquery_dataset_iam_member.bq["audit"].dataset_id == "audit_logs"
    error_message = "BigQuery grant must target the configured dataset."
  }
}
