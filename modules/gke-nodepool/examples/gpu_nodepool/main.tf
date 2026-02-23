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

module "gpu_nodepool" {
  source = "../../"

  project_id   = var.project_id
  cluster_name = var.cluster_name
  location     = "us-central1-a" # GPUs require zonal node pools
  name         = "gpu-pool"

  machine_type = "n1-standard-4"
  disk_size    = 100
  disk_type    = "pd-ssd"

  node_count = {
    initial = 0
    current = 1
  }

  autoscaling = {
    min_node_count = 0
    max_node_count = 5
  }

  # GPU Configuration
  guest_accelerator = {
    type  = "nvidia-tesla-t4"
    count = 1
    gpu_driver = {
      version = "DEFAULT"
    }
  }

  default_labels = {
    environment = "production"
    managed_by  = "terraform"
    team        = "ml"
  }

  labels = {
    workload = "gpu"
    gpu_type = "t4"
    purpose  = "training"
  }

  # Taints to ensure only GPU workloads run on these nodes
  taints = {
    "nvidia.com/gpu" = {
      value  = "present"
      effect = "NO_SCHEDULE"
    }
  }

  service_account_email = var.service_account_email

  management = {
    auto_repair  = true
    auto_upgrade = true
  }
}

output "node_pool_name" {
  description = "The name of the GPU node pool"
  value       = module.gpu_nodepool.name
}

output "node_pool_id" {
  description = "The ID of the GPU node pool"
  value       = module.gpu_nodepool.id
}
