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

variable "vpn_tunnel_uri" {
  description = "The URI of the VPN tunnel."
  type        = string
}

module "ncc" {
  source = "../../"

  project_id          = var.project_id
  ncc_hub_name        = "hybrid-connectivity-hub"
  ncc_hub_description = "NCC Hub for hybrid connectivity via VPN"

  ncc_hub_labels = {
    environment = "production"
    purpose     = "hybrid-connectivity"
  }

  spoke_labels = {
    team = "network-engineering"
  }

  hybrid_spokes = {
    vpn-to-onprem = {
      location                   = "us-central1"
      type                       = "vpn"
      uris                       = [var.vpn_tunnel_uri]
      site_to_site_data_transfer = true
      description                = "VPN connection to on-premises datacenter"
      labels = {
        connectivity = "vpn"
        destination  = "on-premises"
      }
    }
  }
}

output "hub_id" {
  description = "The ID of the NCC hub"
  value       = module.ncc.hub.id
}

output "hybrid_spokes" {
  description = "The hybrid spokes created"
  value       = module.ncc.hybrid_spokes
}
