run "plan_basic_service" {
  command = plan

  variables {
    project_id = "test-project"
    region     = "us-central1"
    name       = "test-service"

    containers = {
      app = {
        image = "gcr.io/google-samples/hello-app:1.0"
      }
    }

    default_labels = {
      managed_by = "terraform"
    }

    labels = {
      env = "test"
    }
  }

  # Verify Service
  assert {
    condition     = google_cloud_run_v2_service.service[0].name == "test-service"
    error_message = "Service name incorrect"
  }

  # Verify Labels
  assert {
    condition     = google_cloud_run_v2_service.service[0].labels["env"] == "test"
    error_message = "Should have user label env=test"
  }

  assert {
    condition     = google_cloud_run_v2_service.service[0].labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  assert {
    condition     = google_cloud_run_v2_service.service[0].labels["resourcetype"] == "cloud-run-v2"
    error_message = "Should have automatic label resourcetype=cloud-run-v2"
  }
}
