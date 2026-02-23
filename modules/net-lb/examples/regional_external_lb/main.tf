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
  default     = "elb-vpc"
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

module "elb" {
  source = "../../"

  default_labels = {
    environment = "prod"
    type        = "external"
  }

  resource_prefix = "prod"

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
    elb-backend = {
      name                  = "elb-backend"
      region                = "us-central1"
      load_balancing_scheme = "EXTERNAL"
      protocol              = "TCP"
      health_checks         = ["tcp-check"]
      project               = var.project_id
    }
  }

  compute_forwarding_rules = {
    elb-forwarding-rule = {
      name                  = "elb-forwarding-rule"
      region                = "us-central1"
      load_balancing_scheme = "EXTERNAL"
      backend_service       = "elb-backend"
      ip_protocol           = "TCP"
      ports                 = ["80"]
      project               = var.project_id
      labels = {
        app = "public-app"
      }
    }
  }
}
