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

variable "hub_network_name" {
  description = "The name of the hub VPC network."
  type        = string
  default     = "hub-vpc"
}

variable "spoke_network_name" {
  description = "The name of the spoke VPC network."
  type        = string
  default     = "spoke-vpc"
}

module "vpc_peering_bidirectional" {
  source = "../../"

  compute_network_peerings = {
    hub_spoke_peering = {
      name                                = "hub-spoke-peering"
      network                             = "projects/${var.project_id}/global/networks/${var.hub_network_name}"
      peer_network                        = "projects/${var.project_id}/global/networks/${var.spoke_network_name}"
      export_custom_routes                = true
      import_custom_routes                = true
      export_subnet_routes_with_public_ip = false
      import_subnet_routes_with_public_ip = false
      stack_type                          = "IPV4_ONLY"
      peer_create_peering                 = true # Creates both local and remote peering
    }
  }

  resource_prefix = "prod"
  join_separator  = "-"
}

output "local_peering" {
  description = "Local VPC peering connection"
  value = {
    name    = module.vpc_peering_bidirectional.network_peerings["hub_spoke_peering"].name
    state   = module.vpc_peering_bidirectional.network_peerings["hub_spoke_peering"].state
    network = module.vpc_peering_bidirectional.network_peerings["hub_spoke_peering"].network
  }
}

output "remote_peering" {
  description = "Remote VPC peering connection"
  value = {
    name    = module.vpc_peering_bidirectional.network_peerings_remote["hub_spoke_peering"].name
    state   = module.vpc_peering_bidirectional.network_peerings_remote["hub_spoke_peering"].state
    network = module.vpc_peering_bidirectional.network_peerings_remote["hub_spoke_peering"].network
  }
}
