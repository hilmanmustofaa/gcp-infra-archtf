run "plan_egress_deny_rule" {
  command = plan

  variables {
    compute_firewalls = {
      deny_external_db = {
        project     = "test-project"
        name        = "deny-external-db"
        network     = "test-vpc"
        description = "Deny outbound traffic to external databases"
        direction   = "EGRESS"
        priority    = 900
        disabled    = false

        allow = []

        deny = [
          {
            protocol = "tcp"
            ports    = ["3306", "5432", "1433"]
          }
        ]

        source_ranges      = []
        destination_ranges = ["0.0.0.0/0"]
        source_tags        = []
        target_tags        = ["app-server"]
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
    condition     = output.firewall_rules["deny_external_db"].name == "deny-external-db"
    error_message = "Firewall rule name is incorrect"
  }

  # Verify direction
  assert {
    condition     = output.firewall_rules["deny_external_db"].direction == "EGRESS"
    error_message = "Firewall rule direction should be EGRESS"
  }

  # Verify priority
  assert {
    condition     = output.firewall_rules["deny_external_db"].priority == 900
    error_message = "Firewall rule priority is incorrect"
  }

  # Verify deny rules
  assert {
    condition     = length(output.firewall_rules["deny_external_db"].deny) == 1
    error_message = "Expected 1 deny rule"
  }

  # Verify destination ranges
  assert {
    condition     = contains(output.firewall_rules["deny_external_db"].destination_ranges, "0.0.0.0/0")
    error_message = "Destination ranges should include 0.0.0.0/0"
  }

  # Verify target tags
  assert {
    condition     = contains(output.firewall_rules["deny_external_db"].target_tags, "app-server")
    error_message = "Target tags should include app-server"
  }

  # Verify no allow rules
  assert {
    condition     = length(output.firewall_rules["deny_external_db"].allow) == 0
    error_message = "Should have no allow rules"
  }
}
