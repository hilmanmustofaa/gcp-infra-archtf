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
  description = "The ID of the project where the NAT will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "nat-vpc"
}

# Create VPC and Subnet
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

# Create Router
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  network = google_compute_network.vpc.name
  region  = "us-central1"
  project = var.project_id
}

# Create External IP for NAT
resource "google_compute_address" "nat_ip" {
  name    = "nat-manual-ip"
  region  = "us-central1"
  project = var.project_id
}

module "cloud_nat" {
  source = "../../"

  resource_prefix = "prod"

  router_lookup = {
    "${var.network_name}-router" = {
      name = google_compute_router.router.name
    }
  }

  nat_ip_lookup = {
    "nat-manual-ip" = {
      self_link = google_compute_address.nat_ip.self_link
    }
  }

  network_lookup = {
    "${var.network_name}-subnet" = {
      self_link = google_compute_subnetwork.subnet.self_link
    }
  }

  compute_router_nats = {
    basic-nat = {
      name                               = "basic-nat"
      project                            = var.project_id
      region                             = "us-central1"
      router                             = "${var.network_name}-router"
      nat_ip_allocate_option             = "MANUAL_ONLY"
      nat_ips                            = ["nat-manual-ip"]
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

      subnetwork = {
        "${var.network_name}-subnet" = {
          name                    = "${var.network_name}-subnet"
          source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
        }
      }

      log_config = {
        enable = true
        filter = "ERRORS_ONLY"
      }
    }
  }
}

output "nat_name" {
  description = "Name of the created Cloud NAT"
  value       = module.cloud_nat.nat_names["basic-nat"]
}
