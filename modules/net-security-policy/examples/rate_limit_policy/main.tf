terraform {
  required_version = ">= 1.10.2"

  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = ">= 6.50.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
}

variable "project_id" {
  description = "The ID of the project where the security policy will be created."
  type        = string
}

variable "rate_limit_threshold" {
  description = "Number of requests per minute before rate limiting kicks in."
  type        = number
  default     = 100
}

module "rate_limit_policy" {
  source = "../../"

  resource_prefix = "prod"

  compute_security_policies = {
    ddos-protection = {
      name        = "ddos-protection"
      description = "Cloud Armor policy with rate limiting for DDoS protection"
      project     = var.project_id
      type        = "CLOUD_ARMOR"
      rule = [
        {
          action      = "rate_based_ban"
          priority    = 100
          description = "Rate limit excessive requests"
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
              count        = var.rate_limit_threshold
              interval_sec = 60
            }
          }
          redirect_options = []
        },
        {
          action      = "allow"
          priority    = 1000
          description = "Allow legitimate traffic"
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

output "policy_id" {
  description = "The ID of the security policy"
  value       = module.rate_limit_policy.policies["ddos-protection"].id
}

output "policy_name" {
  description = "The name of the security policy"
  value       = module.rate_limit_policy.policies["ddos-protection"].name
}
