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
  description = "The ID of the project where the VPC peering will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the local VPC network."
  type        = string
  default     = "dev-vpc"
}

variable "peer_network_name" {
  description = "The name of the peer VPC network."
  type        = string
  default     = "shared-vpc"
}

module "vpc_peering_basic" {
  source = "../../"

  compute_network_peerings = {
    dev_to_shared = {
      name                                = "dev-to-shared-peering"
      network                             = "projects/${var.project_id}/global/networks/${var.network_name}"
      peer_network                        = "projects/${var.project_id}/global/networks/${var.peer_network_name}"
      export_custom_routes                = false
      import_custom_routes                = true
      export_subnet_routes_with_public_ip = false
      import_subnet_routes_with_public_ip = false
      stack_type                          = "IPV4_ONLY"
      peer_create_peering                 = false
    }
  }

  resource_prefix = "dev"
  join_separator  = "-"
}

output "peering_state" {
  description = "State of the VPC peering"
  value       = module.vpc_peering_basic.network_peerings["dev_to_shared"].state
}

output "peering_name" {
  description = "Name of the VPC peering"
  value       = module.vpc_peering_basic.network_peerings["dev_to_shared"].name
}
