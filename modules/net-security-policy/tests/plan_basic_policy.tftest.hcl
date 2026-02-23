run "plan_basic_policy" {
  command = plan

  variables {
    resource_prefix = "test"

    compute_security_policies = {
      policy-1 = {
        name        = "policy-1"
        description = "Basic security policy"
        project     = "test-project"
        type        = "CLOUD_ARMOR"
        rule = [
          {
            action      = "allow"
            priority    = 1000
            description = "Allow all traffic"
            preview     = false
            match = {
              versioned_expr = "SRC_IPS_V1"
              config = {
                src_ip_ranges = ["*"]
              }
              expr = {
                expression = null
              }
            }
            rate_limit_options = []
            redirect_options   = []
          },
          {
            action      = "deny(403)"
            priority    = 2147483647
            description = "Default deny rule"
            preview     = false
            match = {
              versioned_expr = "SRC_IPS_V1"
              config = {
                src_ip_ranges = ["*"]
              }
              expr = {
                expression = null
              }
            }
            rate_limit_options = []
            redirect_options   = []
          }
        ]
        advanced_options_config    = null
        adaptive_protection_config = null
      }
    }
  }

  # Verify Security Policy
  assert {
    condition     = google_compute_security_policy.compute_security_policies["policy-1"].name == "test-policy-1"
    error_message = "Security policy name incorrect"
  }

  assert {
    condition     = google_compute_security_policy.compute_security_policies["policy-1"].type == "CLOUD_ARMOR"
    error_message = "Security policy type incorrect"
  }

  # Verify Rules
  assert {
    condition     = length(google_compute_security_policy.compute_security_policies["policy-1"].rule) == 2
    error_message = "Should have 2 rules"
  }
}
