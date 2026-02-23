run "plan_basic_ingress_rule" {
  command = plan

  variables {
    compute_firewalls = {
      allow_http_https = {
        project     = "test-project"
        name        = "allow-http-https"
        network     = "test-vpc"
        description = "Allow HTTP and HTTPS traffic from internet"
        direction   = "INGRESS"
        priority    = 1000
        disabled    = false

        allow = [
          {
            protocol = "tcp"
            ports    = ["80", "443"]
          }
        ]

        deny = []

        source_ranges      = ["0.0.0.0/0"]
        destination_ranges = []
        source_tags        = []
        target_tags        = ["web-server"]

        log_config = {
          metadata = "INCLUDE_ALL_METADATA"
        }
      }
    }

    network_self_links = {
      test-vpc = "projects/test-project/global/networks/test-vpc"
    }
  }

  # Verify firewall rule is created
  assert {
    condition     = length(output.firewall_rules) == 1
    error_message = "Expected 1 firewall rule to be created"
  }

  # Verify rule name
  assert {
    condition     = output.firewall_rules["allow_http_https"].name == "allow-http-https"
    error_message = "Firewall rule name is incorrect"
  }

  # Verify direction
  assert {
    condition     = output.firewall_rules["allow_http_https"].direction == "INGRESS"
    error_message = "Firewall rule direction should be INGRESS"
  }

  # Verify priority
  assert {
    condition     = output.firewall_rules["allow_http_https"].priority == 1000
    error_message = "Firewall rule priority is incorrect"
  }

  # Verify allow rules
  assert {
    condition     = length(output.firewall_rules["allow_http_https"].allow) == 1
    error_message = "Expected 1 allow rule"
  }

  # Verify source ranges
  assert {
    condition     = contains(output.firewall_rules["allow_http_https"].source_ranges, "0.0.0.0/0")
    error_message = "Source ranges should include 0.0.0.0/0"
  }

  # Verify target tags
  assert {
    condition     = contains(output.firewall_rules["allow_http_https"].target_tags, "web-server")
    error_message = "Target tags should include web-server"
  }

  # Verify log config
  assert {
    condition     = output.firewall_rules["allow_http_https"].log_config[0].metadata == "INCLUDE_ALL_METADATA"
    error_message = "Log config metadata is incorrect"
  }
}
