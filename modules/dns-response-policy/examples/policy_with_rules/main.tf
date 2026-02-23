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
  region  = "us-central1"
}

variable "project_id" {
  description = "The ID of the project."
  type        = string
}

# Create a VPC for the policy
resource "google_compute_network" "vpc" {
  name                    = "policy-vpc"
  auto_create_subnetworks = false
}

module "policy_with_rules" {
  source = "../../"

  project_id = var.project_id
  name       = "rules-policy"

  networks = {
    policy-vpc = google_compute_network.vpc.self_link
  }

  rules = {
    "override-example" = {
      dns_name = "example.com."
      local_data = {
        "A" = {
          rrdatas = ["10.0.0.1"]
          ttl     = 300
        }
      }
    }
    "bypass-google" = {
      dns_name = "google.com."
      behavior = "bypassResponsePolicy"
    }
  }


}
