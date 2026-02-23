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
  default     = "lb-vpc"
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

module "lb" {
  source = "../../"

  resource_prefix = "prod"

  default_labels = {
    environment = "prod"
    team        = "network"
  }

  compute_health_checks = {
    http-check = {
      name = "http-check"
      http_health_check = {
        port = 80
      }
      project = var.project_id
    }
  }

  compute_backend_services = {
    web-backend = {
      name          = "web-backend"
      health_checks = ["http-check"]
      project       = var.project_id
    }
  }

  compute_url_maps = {
    web-map = {
      name            = "web-map"
      default_service = "web-backend"
      project         = var.project_id
    }
  }

  compute_target_https_proxies = {
    web-proxy = {
      name    = "web-proxy"
      url_map = "web-map"
      project = var.project_id
    }
  }

  compute_global_forwarding_rules = {
    web-lb-rule = {
      name       = "web-lb-rule"
      target     = "web-proxy"
      port_range = "443"
      project    = var.project_id
      labels = {
        service = "web"
      }
    }
  }
}

output "lb_ip" {
  description = "IP address of the load balancer"
  value       = module.lb.global_forwarding_rules["web-lb-rule"].ip_address
}
