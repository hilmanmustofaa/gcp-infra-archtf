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
  description = "The ID of the project for the node pool."
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "service_account_email" {
  description = "Service account email for the nodes."
  type        = string
}

module "basic_nodepool" {
  source = "../../"

  project_id   = var.project_id
  cluster_name = var.cluster_name
  location     = "us-central1"
  name         = "general-purpose-pool"

  machine_type = "e2-standard-4"
  disk_size    = 100
  disk_type    = "pd-standard"

  node_count = {
    initial = 1
    current = 3
  }

  autoscaling = {
    min_node_count = 1
    max_node_count = 10
  }

  default_labels = {
    environment = "production"
    managed_by  = "terraform"
    team        = "platform"
  }

  labels = {
    workload = "general"
    pool     = "default"
  }

  service_account_email = var.service_account_email

  management = {
    auto_repair  = true
    auto_upgrade = true
  }
}

output "node_pool_name" {
  description = "The name of the node pool"
  value       = module.basic_nodepool.name
}

output "node_pool_id" {
  description = "The ID of the node pool"
  value       = module.basic_nodepool.id
}
