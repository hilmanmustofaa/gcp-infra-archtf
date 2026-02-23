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
}

variable "project_id" {
  description = "The ID of the project for GKE Hub."
  type        = string
}

variable "cluster_1_id" {
  description = "Full resource ID of the first GKE cluster."
  type        = string
  default     = "projects/my-project/locations/us-central1/clusters/cluster-1"
}

variable "cluster_2_id" {
  description = "Full resource ID of the second GKE cluster."
  type        = string
  default     = "projects/my-project/locations/us-east1/clusters/cluster-2"
}

module "gke_hub" {
  source = "../../"

  project_id = var.project_id

  clusters = {
    cluster-1 = var.cluster_1_id
    cluster-2 = var.cluster_2_id
  }

  default_labels = {
    environment = "production"
    managed_by  = "terraform"
    fleet       = "main"
  }

  features = {}
}

output "memberships" {
  description = "GKE Hub memberships"
  value       = module.gke_hub.memberships
}
