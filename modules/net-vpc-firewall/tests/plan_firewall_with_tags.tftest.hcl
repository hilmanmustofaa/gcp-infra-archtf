run "plan_firewall_with_tags" {
  command = plan

  variables {
    compute_firewalls = {
      allow_internal_ssh = {
        project     = "test-project"
        name        = "allow-internal-ssh"
        network     = "test-vpc"
        description = "Allow SSH between tagged instances"
        direction   = "INGRESS"
        priority    = 1000
        disabled    = false

        allow = [
          {
            protocol = "tcp"
            ports    = ["22"]
          }
        ]

        deny = []

        source_ranges      = []
        destination_ranges = []
        source_tags        = ["bastion"]
        target_tags        = ["ssh-enabled"]
      }

      allow_lb_health_check = {
        project     = "test-project"
        name        = "allow-lb-health-check"
        network     = "test-vpc"
        description = "Allow health checks from load balancer"
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

        source_ranges      = ["35.191.0.0/16", "130.211.0.0/22"]
        destination_ranges = []
        source_tags        = []
        target_tags        = ["lb-backend"]
      }
    }

    network_self_links = {
      test-vpc = "projects/test-project/global/networks/test-vpc"
    }
  }

  # Verify 2 firewall rules are created
  assert {
    condition     = length(output.firewall_rules) == 2
    error_message = "Expected 2 firewall rules to be created"
  }

  # Verify SSH rule uses source tags
  assert {
    condition     = contains(output.firewall_rules["allow_internal_ssh"].source_tags, "bastion")
    error_message = "SSH rule should have bastion as source tag"
  }

  # Verify SSH rule uses target tags
  assert {
    condition     = contains(output.firewall_rules["allow_internal_ssh"].target_tags, "ssh-enabled")
    error_message = "SSH rule should have ssh-enabled as target tag"
  }

  # Verify SSH rule has no source ranges (tag-based only)
  assert {
    condition     = output.firewall_rules["allow_internal_ssh"].source_ranges == null
    error_message = "SSH rule should not have source ranges when using tags"
  }

  # Verify health check rule uses source ranges
  assert {
    condition = (
      contains(output.firewall_rules["allow_lb_health_check"].source_ranges, "35.191.0.0/16") &&
      contains(output.firewall_rules["allow_lb_health_check"].source_ranges, "130.211.0.0/22")
    )
    error_message = "Health check rule should have GCP load balancer IP ranges"
  }

  # Verify health check rule uses target tags
  assert {
    condition     = contains(output.firewall_rules["allow_lb_health_check"].target_tags, "lb-backend")
    error_message = "Health check rule should have lb-backend as target tag"
  }

  # Verify both rules are INGRESS
  assert {
    condition = (
      output.firewall_rules["allow_internal_ssh"].direction == "INGRESS" &&
      output.firewall_rules["allow_lb_health_check"].direction == "INGRESS"
    )
    error_message = "Both rules should be INGRESS"
  }
}
