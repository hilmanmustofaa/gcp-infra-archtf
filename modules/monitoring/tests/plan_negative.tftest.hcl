# ============================================================================
# Plan Test: monitoring validation negatives
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"

  default_labels = {
    env     = "test"
    project = "demo"
    owner   = "platform"
  }
}

# Invalid alert policy combiner => fail.
run "bad_combiner" {
  command = plan

  variables {
    alert_policies = {
      bad = {
        display_name = "x"
        combiner     = "MAYBE"
        conditions = [
          {
            display_name = "c"
            condition_threshold = {
              filter     = "metric.type=\"x\""
              comparison = "COMPARISON_GT"
              duration   = "60s"
            }
          }
        ]
      }
    }
  }

  expect_failures = [var.alert_policies]
}

# Alert condition with neither threshold nor absent => fail.
run "condition_neither" {
  command = plan

  variables {
    alert_policies = {
      bad = {
        display_name = "x"
        conditions = [
          {
            display_name = "c"
          }
        ]
      }
    }
  }

  expect_failures = [var.alert_policies]
}

# Uptime check with both http and tcp => fail.
run "uptime_both" {
  command = plan

  variables {
    uptime_checks = {
      bad = {
        display_name = "x"
        monitored_resource = {
          type   = "uptime_url"
          labels = { host = "example.com" }
        }
        http_check = { path = "/" }
        tcp_check  = { port = 443 }
      }
    }
  }

  expect_failures = [var.uptime_checks]
}
