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
  default     = "classic-vpn-vpc"
}

# Create VPC
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

# Create Target VPN Gateway (Classic)
resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "classic-vpn-gw"
  network = google_compute_network.vpc.id
  region  = "us-central1"
  project = var.project_id
}

# Create Static IP for VPN Gateway
resource "google_compute_address" "vpn_ip" {
  name    = "classic-vpn-ip"
  region  = "us-central1"
  project = var.project_id
}

# Create Forwarding Rules
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
  project     = var.project_id
  region      = "us-central1"
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
  project     = var.project_id
  region      = "us-central1"
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
  project     = var.project_id
  region      = "us-central1"
}

module "classic_vpn" {
  source = "../../"

  default_labels = {
    environment = "prod"
    team        = "network"
    type        = "classic"
  }

  compute_vpn_tunnels = {
    classic_tunnel = {
      name                    = "classic-tunnel"
      shared_secret           = "secret123"
      vpn_gateway             = google_compute_vpn_gateway.target_gateway.id
      peer_ip                 = "203.0.113.1"
      ike_version             = 2
      local_traffic_selector  = ["10.0.0.0/24"]
      remote_traffic_selector = ["192.168.0.0/24"]
      region                  = "us-central1"
      project                 = var.project_id
      labels = {
        tunnel-id = "classic-1"
      }
    }
  }
}

output "vpn_gateway_ip" {
  description = "IP address of the VPN gateway"
  value       = google_compute_address.vpn_ip.address
}

output "tunnel_self_link" {
  description = "Self link of the VPN tunnel"
  value       = module.classic_vpn.vpn_tunnels["classic_tunnel"].self_link
}
