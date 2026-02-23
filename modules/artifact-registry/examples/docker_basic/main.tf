terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast2"
}

variable "project_id" {
  type        = string
  description = "Project ID for this example."
}

locals {
  # Workspace-level default labels (env/product/cost_center/etc)
  workspace_default_labels = {
    env         = "dev"
    product     = "ads"
    cost_center = "cc-1234"
    owner_team  = "platform"
  }
}

module "artifact_registry_docker" {
  source = "../.."

  project_id    = var.project_id
  location      = "asia-southeast2"
  repository_id = "ads-app-images"
  format        = "DOCKER"

  docker_immutable_tags = true

  cleanup_policy_dry_run = true
  cleanup_policies = {
    delete-untagged = {
      action = "DELETE"
      condition = {
        tag_state = "UNTAGGED"
      }
    }
  }

  # Module-level extra labels (optional)
  labels = {
    component = "ads-backend"
  }
}

locals {
  # Final labels yang bisa kamu kirim ke FinOps pipeline/reporting
  artifact_registry_docker_effective_labels = merge(
    local.workspace_default_labels,
    module.artifact_registry_docker.finops_labels
  )
}

output "repository_url" {
  value       = module.artifact_registry_docker.repository_url
  description = "Docker Artifact Registry URL."
}

output "artifact_registry_finops_labels" {
  value       = local.artifact_registry_docker_effective_labels
  description = "Merged FinOps labels for this Docker repository (workspace + module)."
}
