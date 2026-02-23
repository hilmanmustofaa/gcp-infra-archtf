terraform {
  required_version = ">= 1.10.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.50.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

variable "project_id" {
  description = "The ID of the project where the firewall rules will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "my-vpc"
}

module "firewall_basic" {
  source = "../../"

  compute_firewalls = {
    allow_ssh = {
      project     = var.project_id
      name        = "allow-ssh"
      network     = "projects/${var.project_id}/global/networks/${var.network_name}"
      description = "Allow SSH from IAP"
      direction   = "INGRESS"
      priority    = 1000

      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]

      deny = []

      source_ranges = ["35.235.240.0/20"] # IAP IP range
      target_tags   = ["ssh-enabled"]

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }

    allow_http_https = {
      project     = var.project_id
      name        = "allow-http-https"
      network     = "projects/${var.project_id}/global/networks/${var.network_name}"
      description = "Allow HTTP and HTTPS from internet"
      direction   = "INGRESS"
      priority    = 1000

      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      ]

      deny = []

      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["web-server"]
    }
  }

  network_self_links = {}

  resource_prefix = "prod"
  join_separator  = "-"
}

output "firewall_rules" {
  description = "Created firewall rules"
  value       = module.firewall_basic.firewall_rules
}

output "firewall_self_links" {
  description = "Self links of firewall rules"
  value       = module.firewall_basic.firewall_rules_self_links
}
