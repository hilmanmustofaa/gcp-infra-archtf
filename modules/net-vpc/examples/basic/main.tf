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

module "vpc_basic" {
  source = "../../"

  networks = {
    dev_vpc = {
      project                 = var.project_id
      name                    = "dev-vpc"
      description             = "Development VPC network"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
      mtu                     = 1460
    }
  }

  subnetworks = {
    dev_subnet_us_central1 = {
      project                  = var.project_id
      name                     = "dev-subnet-us-central1"
      network                  = "dev_vpc"
      description              = "Development subnet in us-central1"
      ip_cidr_range            = "10.0.0.0/24"
      region                   = "us-central1"
      private_ip_google_access = true
    }

    dev_subnet_us_east1 = {
      project                  = var.project_id
      name                     = "dev-subnet-us-east1"
      network                  = "dev_vpc"
      description              = "Development subnet in us-east1"
      ip_cidr_range            = "10.1.0.0/24"
      region                   = "us-east1"
      private_ip_google_access = true
    }
  }

  compute_routes = {}

  resource_prefix = "dev"
  join_separator  = "-"
}

output "network_id" {
  description = "The ID of the VPC network"
  value       = module.vpc_basic.networks["dev_vpc"].id
}

output "network_self_link" {
  description = "The self link of the VPC network"
  value       = module.vpc_basic.networks["dev_vpc"].self_link
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value = {
    for k, v in module.vpc_basic.subnetworks : k => v.id
  }
}
