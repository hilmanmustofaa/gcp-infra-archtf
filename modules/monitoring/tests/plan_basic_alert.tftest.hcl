# ============================================================================
# Plan Test: alert policy + channel reference resolution + FinOps user_labels
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"

  default_labels = {
    env     = "prod"
    project = "platform"
    owner   = "sre-team"
  }
}

run "plan_basic_alert" {
  command = plan

  variables {
    notification_channels = {
      email = {
        display_name = "SRE Email"
        type         = "email"
        labels       = { email_address = "sre@example.com" }
      }
    }

    alert_policies = {
      cpu = {
        display_name          = "High CPU"
        combiner              = "OR"
        notification_channels = ["email"] # logical key, resolved to channel id
        conditions = [
          {
            display_name = "CPU > 80%"
            condition_threshold = {
              filter           = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
              comparison       = "COMPARISON_GT"
              threshold_value  = 0.8
              duration         = "300s"
              alignment_period = "60s"
              trigger_count    = 1
            }
          }
        ]
      }
    }
  }

  assert {
    condition     = google_monitoring_alert_policy.policies["cpu"].combiner == "OR"
    error_message = "Alert policy combiner must be OR."
  }

  # FinOps labels propagate to alert policy user_labels.
  assert {
    condition     = google_monitoring_alert_policy.policies["cpu"].user_labels["tf_module"] == "monitoring"
    error_message = "Alert policy must carry tf_module=monitoring user_label."
  }

  assert {
    condition     = google_monitoring_alert_policy.policies["cpu"].user_labels["env"] == "prod"
    error_message = "Alert policy must carry env user_label."
  }

  # Exactly one channel reference is configured (resolution to id happens at apply).
  assert {
    condition     = length(google_monitoring_alert_policy.policies["cpu"].notification_channels) == 1
    error_message = "Alert policy must reference exactly one notification channel."
  }
}
