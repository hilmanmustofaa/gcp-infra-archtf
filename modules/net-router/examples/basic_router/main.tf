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
  description = "The ID of the project where the router will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "default"
}

module "router" {
  source = "../../"

  resource_prefix = "prod"

  compute_routers = {
    main-router = {
      name                          = "main-router"
      network                       = "projects/${var.project_id}/global/networks/${var.network_name}"
      region                        = "us-central1"
      project                       = var.project_id
      description                   = "Main Cloud Router for VPN connectivity"
      encrypted_interconnect_router = false
      bgp                           = null
      labels = {
        purpose = "vpn"
      }
    }
  }
}

output "router_id" {
  description = "The ID of the router"
  value       = module.router.routers["main-router"].id
}

output "router_name" {
  description = "The name of the router"
  value       = module.router.routers["main-router"].name
}
