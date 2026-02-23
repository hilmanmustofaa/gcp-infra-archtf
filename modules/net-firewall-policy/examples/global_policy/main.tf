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
  description = "The ID of the project where the policy will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "global-policy-vpc"
}

# Create VPC
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

module "global_policy" {
  source = "../../"

  name      = "global-policy"
  parent_id = var.project_id
  region    = "global"

  attachments = {
    vpc-attachment = google_compute_network.vpc.self_link
  }

  ingress_rules = {
    allow-ssh = {
      priority    = 1000
      action      = "allow"
      description = "Allow SSH from anywhere"
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
      priority    = 65535
      action      = "deny"
      description = "Deny all egress"
      match = {
        destination_ranges = ["0.0.0.0/0"]
        layer4_configs     = [{ protocol = "all" }]
      }
    }
  }
}

output "policy_id" {
  description = "The ID of the firewall policy"
  value       = module.global_policy.id
}
