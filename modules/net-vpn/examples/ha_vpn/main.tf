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
  description = "The ID of the project where the VPN will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "vpn-vpc"
}

# Create VPC and Router for VPN
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

resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  network = google_compute_network.vpc.name
  region  = "us-central1"
  project = var.project_id
  bgp {
    asn = 64514
  }
}

# Create External VPN Gateway (representing on-prem or other cloud)
resource "google_compute_external_vpn_gateway" "peer_gw" {
  name            = "peer-gw"
  redundancy_type = "TWO_IPS_REDUNDANCY"
  description     = "Peer VPN Gateway"
  interface {
    id         = 0
    ip_address = "203.0.113.1"
  }
  interface {
    id         = 1
    ip_address = "203.0.113.2"
  }
  project = var.project_id
}

module "ha_vpn" {
  source = "../../"

  default_labels = {
    environment = "prod"
    team        = "network"
  }

  compute_ha_vpn_gateways = {
    ha_gw = {
      name    = "ha-vpn-gw"
      network = google_compute_network.vpc.id
      region  = "us-central1"
      project = var.project_id
      vpn_interfaces = [
        {
          id = 0
        },
        {
          id = 1
        }
      ]
    }
  }

  compute_vpn_tunnels = {
    tunnel_0 = {
      name                            = "ha-tunnel-0"
      shared_secret                   = "secret123"
      vpn_gateway                     = "projects/${var.project_id}/regions/us-central1/vpnGateways/ha-vpn-gw"
      vpn_gateway_interface           = 0
      peer_external_gateway           = google_compute_external_vpn_gateway.peer_gw.id
      peer_external_gateway_interface = 0
      router                          = google_compute_router.router.id
      ike_version                     = 2
      region                          = "us-central1"
      project                         = var.project_id
      labels = {
        tunnel-id = "0"
      }
    }
    tunnel_1 = {
      name                            = "ha-tunnel-1"
      shared_secret                   = "secret123"
      vpn_gateway                     = "projects/${var.project_id}/regions/us-central1/vpnGateways/ha-vpn-gw"
      vpn_gateway_interface           = 1
      peer_external_gateway           = google_compute_external_vpn_gateway.peer_gw.id
      peer_external_gateway_interface = 1
      router                          = google_compute_router.router.id
      ike_version                     = 2
      region                          = "us-central1"
      project                         = var.project_id
      labels = {
        tunnel-id = "1"
      }
    }
  }
}

output "ha_gateway_self_link" {
  description = "Self link of the HA VPN gateway"
  value       = module.ha_vpn.ha_vpn_gateways["ha_gw"].self_link
}

output "tunnel_self_links" {
  description = "Self links of the VPN tunnels"
  value = {
    tunnel0 = module.ha_vpn.vpn_tunnels["tunnel_0"].self_link
    tunnel1 = module.ha_vpn.vpn_tunnels["tunnel_1"].self_link
  }
}
