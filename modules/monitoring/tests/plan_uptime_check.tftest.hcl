# ============================================================================
# Plan Test: uptime check configuration
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

run "plan_uptime_check" {
  command = plan

  variables {
    uptime_checks = {
      api = {
        display_name = "API health"
        timeout      = "10s"
        period       = "60s"
        monitored_resource = {
          type = "uptime_url"
          labels = {
            host       = "api.example.com"
            project_id = "dummy-project"
          }
        }
        http_check = {
          path    = "/healthz"
          port    = 443
          use_ssl = true
        }
      }
    }
  }

  assert {
    condition     = google_monitoring_uptime_check_config.uptime["api"].http_check[0].path == "/healthz"
    error_message = "Uptime check HTTP path must be /healthz."
  }

  assert {
    condition     = google_monitoring_uptime_check_config.uptime["api"].monitored_resource[0].type == "uptime_url"
    error_message = "Uptime check monitored_resource type must be uptime_url."
  }
}
