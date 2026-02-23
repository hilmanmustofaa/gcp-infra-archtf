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

# Create a VPC for the private zone
resource "google_compute_network" "vpc" {
  name                    = "dns-vpc"
  auto_create_subnetworks = false
}

module "dns_private" {
  source = "../../"

  project_id = var.project_id

  # Lookup map for network self_links
  network_lookup = {
    dns-vpc = google_compute_network.vpc
  }

  default_labels = {
    environment = "internal"
    managed_by  = "terraform"
  }

  dns_managed_zones = {
    internal-com = {
      name        = "internal-com"
      dns_name    = "internal.com."
      description = "Private zone for internal.com"
      visibility  = "private"

      private_visibility_config = {
        networks = ["dns-vpc"]
      }

      labels = {
        team = "platform"
      }
    }
  }

  dns_record_sets = {
    db = {
      name         = "db"
      type         = "A"
      ttl          = 300
      managed_zone = "internal-com"
      rrdatas      = ["10.0.0.5"]
    }
  }
}
