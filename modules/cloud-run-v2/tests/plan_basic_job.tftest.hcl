run "plan_basic_job" {
  command = plan

  variables {
    project_id = "test-project"
    region     = "us-central1"
    name       = "test-job"
    create_job = true

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

  # Verify Job
  assert {
    condition     = google_cloud_run_v2_job.job[0].name == "test-job"
    error_message = "Job name incorrect"
  }

  # Verify Labels
  assert {
    condition     = google_cloud_run_v2_job.job[0].labels["env"] == "test"
    error_message = "Should have user label env=test"
  }

  assert {
    condition     = google_cloud_run_v2_job.job[0].labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  assert {
    condition     = google_cloud_run_v2_job.job[0].labels["resourcetype"] == "cloud-run-v2"
    error_message = "Should have automatic label resourcetype=cloud-run-v2"
  }
}
