terraform {
  required_version = ">= 1.10.2"

  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = ">= 6.50.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = "us-central1"
}

variable "project_id" {
  description = "The ID of the project where the GKE cluster will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "default"
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
  default     = "default"
}

module "private_gke_cluster" {
  source = "../../"

  name       = "private-gke-cluster"
  project_id = var.project_id
  location   = "us-central1"

  network    = "projects/${var.project_id}/global/networks/${var.network_name}"
  subnetwork = "projects/${var.project_id}/regions/us-central1/subnetworks/${var.subnet_name}"

  cluster_secondary_range_name  = "pods"
  services_secondary_range_name = "services"

  default_labels = {
    environment = "production"
    managed_by  = "terraform"
    security    = "private"
  }

  # Private cluster configuration
  enable_private_nodes    = true
  enable_private_endpoint = true
  master_ipv4_cidr_block  = "172.16.0.0/28"

  # Master authorized networks
  master_authorized_networks = [
    {
      cidr_block   = "10.0.0.0/8"
      display_name = "internal-network"
    }
  ]

  # Security features
  enable_shielded_nodes = true
  enable_legacy_abac    = false

  # Workload Identity
  workload_pool = "${var.project_id}.svc.id.goog"

  node_locations  = ["us-central1-a", "us-central1-b"]
  release_channel = "REGULAR"
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.private_gke_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = module.private_gke_cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate of the GKE cluster"
  value       = module.private_gke_cluster.ca_certificate
  sensitive   = true
}
