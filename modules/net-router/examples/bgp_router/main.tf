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

variable "asn" {
  description = "The BGP ASN for the router."
  type        = number
  default     = 64512
}

module "bgp_router" {
  source = "../../"

  resource_prefix = "prod"

  compute_routers = {
    bgp-router = {
      name                          = "bgp-router"
      network                       = "projects/${var.project_id}/global/networks/${var.network_name}"
      region                        = "us-central1"
      project                       = var.project_id
      description                   = "BGP-enabled Cloud Router for VPN/Interconnect"
      encrypted_interconnect_router = false
      labels = {
        purpose = "hybrid-connectivity"
        type    = "bgp"
      }
      bgp = {
        asn                = var.asn
        advertise_mode     = "CUSTOM"
        advertised_groups  = ["ALL_SUBNETS"]
        keepalive_interval = 20
        advertised_ip_ranges = [
          {
            range       = "10.0.0.0/8"
            description = "Private network range"
          },
          {
            range       = "192.168.0.0/16"
            description = "Additional private range"
          }
        ]
      }
    }
  }
}

output "router_id" {
  description = "The ID of the BGP router"
  value       = module.bgp_router.routers["bgp-router"].id
}

output "router_name" {
  description = "The name of the BGP router"
  value       = module.bgp_router.routers["bgp-router"].name
}

output "bgp_asn" {
  description = "The BGP ASN of the router"
  value       = module.bgp_router.routers["bgp-router"].bgp[0].asn
}
