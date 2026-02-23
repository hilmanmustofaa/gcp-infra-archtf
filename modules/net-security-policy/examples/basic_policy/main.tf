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

module "security_policy" {
  source = "../../"

  resource_prefix = "prod"

  compute_security_policies = {
    web-policy = {
      name        = "web-policy"
      description = "Cloud Armor policy for web applications"
      project     = var.project_id
      type        = "CLOUD_ARMOR"
      rule = [
        {
          action      = "allow"
          priority    = 1000
          description = "Allow traffic from trusted IPs"
          preview     = false
          match = {
            versioned_expr = "SRC_IPS_V1"
            config = {
              src_ip_ranges = ["10.0.0.0/8", "192.168.0.0/16"]
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
  value       = module.security_policy.policies["web-policy"].id
}

output "policy_name" {
  description = "The name of the security policy"
  value       = module.security_policy.policies["web-policy"].name
}
