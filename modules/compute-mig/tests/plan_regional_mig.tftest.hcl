run "plan_regional_mig" {
  command = plan

  variables {
    project_id        = "test-project"
    name              = "regional-mig"
    location          = "us-central1"
    instance_template = "projects/test-project/global/instanceTemplates/test-template"
    target_size       = 3

    distribution_policy = {
      target_shape = "EVEN"
      zones        = ["us-central1-a", "us-central1-b", "us-central1-c"]
    }

    update_policy = {
      minimal_action  = "REPLACE"
      type            = "PROACTIVE"
      max_surge       = { fixed = 3 }
      max_unavailable = { fixed = 0 }
      min_ready_sec   = 60
    }
  }

  # Verify MIG
  assert {
    condition     = google_compute_region_instance_group_manager.mig[0].name == "regional-mig"
    error_message = "MIG name incorrect"
  }

  assert {
    condition     = google_compute_region_instance_group_manager.mig[0].region == "us-central1"
    error_message = "MIG region incorrect"
  }

  # Verify Distribution Policy
  assert {
    condition     = google_compute_region_instance_group_manager.mig[0].distribution_policy_target_shape == "EVEN"
    error_message = "Target shape incorrect"
  }

  # Verify Update Policy
  assert {
    condition     = google_compute_region_instance_group_manager.mig[0].update_policy[0].type == "PROACTIVE"
    error_message = "Update policy type incorrect"
  }

  assert {
    condition     = google_compute_region_instance_group_manager.mig[0].update_policy[0].min_ready_sec == 60
    error_message = "Min ready sec incorrect"
  }
}
