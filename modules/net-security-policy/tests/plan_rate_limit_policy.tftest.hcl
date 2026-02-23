run "plan_rate_limit_policy" {
  command = plan

  variables {
    resource_prefix = "prod"

    compute_security_policies = {
      rate-limit-policy = {
        name        = "rate-limit-policy"
        description = "Rate limiting policy for DDoS protection"
        project     = "test-project"
        type        = "CLOUD_ARMOR"
        rule = [
          {
            action      = "rate_based_ban"
            priority    = 100
            description = "Rate limit rule"
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
            rate_limit_options = {
              ban_duration_sec = 600
              ban_threshold = {
                count        = 10000
                interval_sec = 60
              }
              conform_action      = "allow"
              enforce_on_key      = "IP"
              enforce_on_key_name = null
              exceed_action       = "deny(429)"
              rate_limit_threshold = {
                count        = 100
                interval_sec = 60
              }
            }
            redirect_options = []
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
    condition     = google_compute_security_policy.compute_security_policies["rate-limit-policy"].name == "prod-rate-limit-policy"
    error_message = "Security policy name incorrect"
  }

  # Verify Rules exist
  assert {
    condition     = length(google_compute_security_policy.compute_security_policies["rate-limit-policy"].rule) == 2
    error_message = "Should have 2 rules"
  }
}
