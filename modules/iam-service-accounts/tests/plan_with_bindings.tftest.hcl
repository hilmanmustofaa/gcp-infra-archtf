variables {
  project_id             = "dummy-project"
  account_id             = "test-sa-bindings"
  service_account_create = true

  description  = "Service account with IAM bindings."
  disabled     = false
  display_name = "SA with bindings."
  generate_key = false
  prefix       = ""

  iam_bindings = {
    sa-token-creator = {
      role = "roles/iam.serviceAccountTokenCreator"
      members = [
        "group:devs@example.com",
      ]
    }
  }

  iam_bindings_additive = {
    sa-logs-writer = {
      role   = "roles/logging.logWriter"
      member = "group:ops@example.com"
    }
  }

  project_iam_bindings = {
    proj-viewer = {
      role = "roles/viewer"
    }
  }

  storage_bucket_iam_bindings = {
    logs-bucket = {
      bucket = "dummy-logs-bucket"
      role   = "roles/storage.objectCreator"
    }
  }

  labels = {
    environment = "test"
    owner       = "platform-team"
  }
}

run "plan_with_bindings" {
  command = plan

  # Hanya sanity-check jumlah resource dari for_each map.

  assert {
    condition     = length(google_service_account_iam_binding.bindings) == 1
    error_message = "Expected exactly one google_service_account_iam_binding."
  }

  assert {
    condition     = length(google_service_account_iam_member.bindings) == 1
    error_message = "Expected exactly one google_service_account_iam_member."
  }

  assert {
    condition     = length(google_project_iam_member.project_iam_members) == 1
    error_message = "Expected exactly one google_project_iam_member."
  }

  assert {
    condition     = length(google_storage_bucket_iam_member.storage_bucket_iam_members) == 1
    error_message = "Expected exactly one google_storage_bucket_iam_member."
  }
}
