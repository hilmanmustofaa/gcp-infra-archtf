run "plan_zonal_mig" {
  command = plan

  variables {
    project_id        = "test-project"
    name              = "zonal-mig"
    location          = "us-central1-a"
    instance_template = "projects/test-project/global/instanceTemplates/test-template"
    target_size       = 2

    auto_healing_policies = {
      health_check      = "projects/test-project/global/healthChecks/test-check"
      initial_delay_sec = 300
    }
  }

  # Verify MIG
  assert {
    condition     = google_compute_instance_group_manager.mig[0].name == "zonal-mig"
    error_message = "MIG name incorrect"
  }

  assert {
    condition     = google_compute_instance_group_manager.mig[0].zone == "us-central1-a"
    error_message = "MIG zone incorrect"
  }

  assert {
    condition     = google_compute_instance_group_manager.mig[0].target_size == 2
    error_message = "Target size incorrect"
  }

  # Verify Auto Healing
  assert {
    condition     = google_compute_instance_group_manager.mig[0].auto_healing_policies[0].initial_delay_sec == 300
    error_message = "Initial delay incorrect"
  }
}
