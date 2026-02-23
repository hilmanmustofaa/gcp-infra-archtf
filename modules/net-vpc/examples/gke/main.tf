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
  description = "The ID of the project where the VPC will be created."
  type        = string
}

module "gke_vpc" {
  source = "../../"

  networks = {
    gke_vpc = {
      project                 = var.project_id
      name                    = "gke-vpc"
      description             = "VPC for GKE clusters"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
      mtu                     = 1460
    }
  }

  subnetworks = {
    gke_subnet = {
      project                  = var.project_id
      name                     = "gke-subnet"
      network                  = "gke_vpc"
      description              = "GKE subnet with secondary ranges"
      ip_cidr_range            = "10.0.0.0/24"
      region                   = "us-central1"
      private_ip_google_access = true

      secondary_ip_range = {
        pods = {
          range_name    = "gke-pods"
          ip_cidr_range = "10.4.0.0/14"
        }
        services = {
          range_name    = "gke-services"
          ip_cidr_range = "10.8.0.0/20"
        }
      }

      log_config = {
        aggregation_interval = "INTERVAL_5_SEC"
        flow_sampling        = 0.5
        metadata             = "INCLUDE_ALL_METADATA"
      }
    }
  }

  compute_routes = {}

  resource_prefix = "prod"
  join_separator  = "-"
}

output "gke_network_name" {
  description = "The name of the GKE VPC network"
  value       = module.gke_vpc.networks["gke_vpc"].name
}

output "gke_subnet_secondary_ranges" {
  description = "Secondary IP ranges for GKE"
  value       = module.gke_vpc.subnetworks["gke_subnet"].secondary_ip_range
}
