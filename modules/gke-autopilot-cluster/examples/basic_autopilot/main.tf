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
  description = "The ID of the project where the GKE Autopilot cluster will be created."
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

module "autopilot_cluster" {
  source = "../../"

  name       = "autopilot-gke-cluster"
  project_id = var.project_id
  location   = "us-central1"

  network    = "projects/${var.project_id}/global/networks/${var.network_name}"
  subnetwork = "projects/${var.project_id}/regions/us-central1/subnetworks/${var.subnet_name}"

  cluster_secondary_range_name  = "pods"
  services_secondary_range_name = "services"

  default_labels = {
    environment  = "production"
    managed_by   = "terraform"
    cluster_type = "autopilot"
  }

  enable_private_nodes    = true
  enable_private_endpoint = false

  workload_pool = "${var.project_id}.svc.id.goog"

  release_channel = "REGULAR"
}

output "cluster_name" {
  description = "The name of the GKE Autopilot cluster"
  value       = module.autopilot_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE Autopilot cluster"
  value       = module.autopilot_cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate of the GKE Autopilot cluster"
  value       = module.autopilot_cluster.ca_certificate
  sensitive   = true
}
