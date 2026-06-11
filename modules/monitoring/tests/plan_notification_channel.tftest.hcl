# ============================================================================
# Plan Test: notification channel + FinOps user_labels
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

run "plan_notification_channel" {
  command = plan

  variables {
    notification_channels = {
      pager = {
        display_name = "PagerDuty"
        type         = "pagerduty"
        labels       = { service_key = "abc123" }
        user_labels  = { team = "oncall" }
      }
    }
  }

  assert {
    condition     = google_monitoring_notification_channel.channels["pager"].type == "pagerduty"
    error_message = "Notification channel type must be pagerduty."
  }

  assert {
    condition     = google_monitoring_notification_channel.channels["pager"].labels["service_key"] == "abc123"
    error_message = "Notification channel config label service_key must be set."
  }

  # FinOps user_labels + module override + per-channel user_labels.
  assert {
    condition     = google_monitoring_notification_channel.channels["pager"].user_labels["tf_resource"] == "notification_channel"
    error_message = "Notification channel user_labels must set tf_resource=notification_channel."
  }

  assert {
    condition     = google_monitoring_notification_channel.channels["pager"].user_labels["team"] == "oncall"
    error_message = "Per-channel user_labels must merge through."
  }
}
