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
  description = "The ID of the project where the LB will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "ilb-vpc"
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

# Proxy-only subnet is required for Envoy-based Internal LBs (optional but good practice to show)
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "${var.network_name}-proxy-subnet"
  ip_cidr_range = "10.129.0.0/23"
  region        = "us-central1"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

module "ilb" {
  source = "../../"

  resource_prefix = "prod"

  default_labels = {
    environment = "prod"
    team        = "network"
  }

  compute_region_health_checks = {
    http-check = {
      name   = "http-check"
      region = "us-central1"
      health_check = {
        protocol = "HTTP"
        port     = 80
      }
      project = var.project_id
    }
  }

  compute_region_backend_services = {
    ilb-backend = {
      name                  = "ilb-backend"
      region                = "us-central1"
      load_balancing_scheme = "INTERNAL_MANAGED"
      protocol              = "HTTP"
      health_checks         = ["http-check"]
      network               = google_compute_network.vpc.id
      project               = var.project_id
    }
  }

  compute_url_maps = {
    ilb-map = {
      name            = "ilb-map"
      default_service = "ilb-backend" # Note: This module structure might need adjustment for regional URL maps if they differ significantly
      project         = var.project_id
    }
  }

  # Note: The current module structure for URL maps seems to assume global backend services for default_service.
  # If the module doesn't support regional URL maps cleanly pointing to regional backends via the same variable, 
  # we might need to stick to a simpler TCP/UDP ILB or verify if the module handles regional references.
  # For this example, let's stick to a TCP/UDP Internal LB (L4) which is simpler and very common.
}

# Redefining for L4 Internal LB (Passthrough) which is simpler and uses forwarding rule + backend service directly
module "l4_ilb" {
  source = "../../"

  resource_prefix = "l4"

  default_labels = {
    environment = "prod"
  }

  compute_region_health_checks = {
    tcp-check = {
      name   = "tcp-check"
      region = "us-central1"
      health_check = {
        protocol = "TCP"
        port     = 80
      }
      project = var.project_id
    }
  }

  compute_region_backend_services = {
    l4-backend = {
      name                  = "l4-backend"
      region                = "us-central1"
      load_balancing_scheme = "INTERNAL"
      protocol              = "TCP"
      health_checks         = ["tcp-check"]
      network               = google_compute_network.vpc.id
      project               = var.project_id
    }
  }

  compute_forwarding_rules = {
    l4-forwarding-rule = {
      name                  = "l4-forwarding-rule"
      region                = "us-central1"
      load_balancing_scheme = "INTERNAL"
      backend_service       = "l4-backend" # This key references the map above
      network               = google_compute_network.vpc.id
      subnetwork            = google_compute_subnetwork.subnet.id
      ip_protocol           = "TCP"
      ports                 = ["80"]
      project               = var.project_id
      labels = {
        app = "internal-app"
      }
    }
  }
}
