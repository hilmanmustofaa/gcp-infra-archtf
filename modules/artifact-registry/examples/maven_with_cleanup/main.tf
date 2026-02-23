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
  workspace_default_labels = {
    env         = "uat"
    product     = "ads"
    cost_center = "cc-5678"
  }
}

module "artifact_registry_maven" {
  source = "../.."

  project_id    = var.project_id
  location      = "asia-southeast2"
  repository_id = "ads-maven-repo"
  format        = "MAVEN"

  maven_allow_snapshot_overwrites = true
  maven_version_policy            = "SNAPSHOT"

  cleanup_policy_dry_run = true
  cleanup_policies = {
    keep-latest = {
      action = "KEEP"
      most_recent_versions = {
        package_name_prefixes = ["com.example.ads"]
        keep_count            = 10
      }
    }
  }

  labels = {
    component = "ads-library"
  }
}

locals {
  artifact_registry_maven_effective_labels = merge(
    local.workspace_default_labels,
    module.artifact_registry_maven.finops_labels
  )
}

output "maven_repository_name" {
  value       = module.artifact_registry_maven.name
  description = "Artifact Registry Maven repository resource name."
}

output "artifact_registry_maven_finops_labels" {
  value       = local.artifact_registry_maven_effective_labels
  description = "Merged FinOps labels for this Maven repository."
}
