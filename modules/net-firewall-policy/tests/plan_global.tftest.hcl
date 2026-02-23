run "plan_global" {
  command = plan

  variables {
    name      = "global-policy"
    parent_id = "test-project"
    region    = "global"

    ingress_rules = {
      allow-ssh = {
        priority = 1000
        action   = "allow"
        match = {
          layer4_configs = [{
            protocol = "tcp"
            ports    = ["22"]
          }]
          source_ranges = ["0.0.0.0/0"]
        }
      }
    }

    egress_rules = {
      deny-all = {
        priority = 65535
        action   = "deny"
        match = {
          destination_ranges = ["0.0.0.0/0"]
          layer4_configs     = [{ protocol = "all" }]
        }
      }
    }
  }

  assert {
    condition     = google_compute_network_firewall_policy.net-global[0].name == "global-policy"
    error_message = "Global policy name should be global-policy"
  }

  assert {
    condition     = google_compute_network_firewall_policy_rule.net-global["ingress/allow-ssh"].action == "allow"
    error_message = "Ingress rule allow-ssh should exist and have action allow"
  }

  assert {
    condition     = google_compute_network_firewall_policy_rule.net-global["egress/deny-all"].action == "deny"
    error_message = "Egress rule deny-all should exist and have action deny"
  }
}
