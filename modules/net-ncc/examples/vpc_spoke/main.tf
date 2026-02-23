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
}

variable "project_id" {
  description = "The ID of the project where NCC will be created."
  type        = string
}

variable "vpc_network_1" {
  description = "The self-link of the first VPC network."
  type        = string
}

variable "vpc_network_2" {
  description = "The self-link of the second VPC network."
  type        = string
}

module "ncc" {
  source = "../../"

  project_id          = var.project_id
  ncc_hub_name        = "production-hub"
  ncc_hub_description = "Production NCC Hub for VPC connectivity"

  ncc_hub_labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  spoke_labels = {
    team = "network-engineering"
  }

  vpc_spokes = {
    vpc-spoke-1 = {
      uri         = var.vpc_network_1
      description = "Primary VPC spoke"
      labels = {
        region = "us-central1"
        tier   = "production"
      }
    }
    vpc-spoke-2 = {
      uri         = var.vpc_network_2
      description = "Secondary VPC spoke"
      labels = {
        region = "us-east1"
        tier   = "production"
      }
    }
  }
}

output "hub_id" {
  description = "The ID of the NCC hub"
  value       = module.ncc.hub.id
}

output "vpc_spokes" {
  description = "The VPC spokes created"
  value       = module.ncc.vpc_spokes
}
