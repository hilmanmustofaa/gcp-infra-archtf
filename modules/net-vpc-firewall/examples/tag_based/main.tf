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

module "firewall_tag_based" {
  source = "../../"

  compute_firewalls = {
    allow_internal_ssh = {
      project     = var.project_id
      name        = "allow-internal-ssh"
      network     = var.network_name
      description = "Allow SSH from bastion hosts"
      direction   = "INGRESS"
      priority    = 1000

      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]

      deny = []

      source_tags = ["bastion"]
      target_tags = ["ssh-enabled"]

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }

    allow_db_from_app = {
      project     = var.project_id
      name        = "allow-db-from-app"
      network     = var.network_name
      description = "Allow database connections from app servers"
      direction   = "INGRESS"
      priority    = 1000

      allow = [
        {
          protocol = "tcp"
          ports    = ["5432", "3306"]
        }
      ]

      deny = []

      source_tags = ["app-server"]
      target_tags = ["database"]
    }

    allow_lb_health_checks = {
      project     = var.project_id
      name        = "allow-lb-health-checks"
      network     = var.network_name
      description = "Allow health checks from GCP load balancers"
      direction   = "INGRESS"
      priority    = 1000

      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      ]

      deny = []

      source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
      target_tags   = ["lb-backend"]
    }
  }

  network_self_links = {
    "${var.network_name}" = "projects/${var.project_id}/global/networks/${var.network_name}"
  }
}

output "internal_firewall_rules" {
  description = "Internal firewall rules"
  value = {
    for k, v in module.firewall_tag_based.firewall_rules : k => {
      name        = v.name
      source_tags = v.source_tags
      target_tags = v.target_tags
    }
  }
}
