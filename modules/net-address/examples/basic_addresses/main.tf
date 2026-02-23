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
  description = "The ID of the project where the addresses will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "address-vpc"
}

# Create VPC and Subnet for Internal Addresses
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

module "addresses" {
  source = "../../"

  project_id = var.project_id

  default_labels = {
    environment = "prod"
    team        = "network"
  }

  external_addresses = {
    ext-web = {
      name        = "web-lb-ip"
      region      = "us-central1"
      description = "External IP for Web Load Balancer"
      labels = {
        service = "web"
      }
    }
  }

  internal_addresses = {
    int-db = {
      name        = "db-internal-ip"
      region      = "us-central1"
      subnetwork  = google_compute_subnetwork.subnet.id
      address     = "10.0.0.10"
      description = "Internal IP for Database"
      labels = {
        service = "database"
      }
    }
  }

  global_addresses = {
    global-lb = {
      name        = "global-lb-ip"
      description = "Global IP for Global Load Balancer"
      ip_version  = "IPV4"
      labels = {
        service = "global-lb"
      }
    }
  }

  psa_addresses = {
    psa-range = {
      name          = "google-managed-services-range"
      address       = "10.10.0.0"
      prefix_length = 16
      network       = google_compute_network.vpc.id
      description   = "Range for Private Service Access"
    }
  }
}

output "external_ip" {
  description = "Allocated external IP address"
  value       = module.addresses.external_addresses["web-lb-ip"].address
}

output "internal_ip" {
  description = "Allocated internal IP address"
  value       = module.addresses.internal_addresses["db-internal-ip"].address
}

output "global_ip" {
  description = "Allocated global IP address"
  value       = module.addresses.global_addresses["global-lb-ip"].address
}
