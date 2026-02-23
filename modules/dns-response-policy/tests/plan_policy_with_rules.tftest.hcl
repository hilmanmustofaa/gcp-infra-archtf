run "plan_policy_with_rules" {
  command = plan

  variables {
    project_id = "test-project"
    name       = "rules-policy"

    networks = {
      vpc-1 = "projects/test-project/global/networks/vpc-1"
    }

    rules = {
      "rule-1" = {
        dns_name = "example.com."
        local_data = {
          "A" = {
            rrdatas = ["1.2.3.4"]
            ttl     = 300
          }
        }
      }
      "rule-2" = {
        dns_name = "google.com."
        behavior = "bypassResponsePolicy"
      }
    }


  }

  # Verify Response Policy
  assert {
    condition     = google_dns_response_policy.default[0].response_policy_name == "rules-policy"
    error_message = "Policy name incorrect"
  }

  # Verify Network Binding
  assert {
    condition     = google_dns_response_policy.default[0].networks[0].network_url == "projects/test-project/global/networks/vpc-1"
    error_message = "Network URL incorrect"
  }

  # Verify Rules
  assert {
    condition     = google_dns_response_policy_rule.default["rule-1"].dns_name == "example.com."
    error_message = "Rule 1 DNS name incorrect"
  }

  assert {
    condition     = google_dns_response_policy_rule.default["rule-2"].behavior == "bypassResponsePolicy"
    error_message = "Rule 2 behavior incorrect"
  }


}
