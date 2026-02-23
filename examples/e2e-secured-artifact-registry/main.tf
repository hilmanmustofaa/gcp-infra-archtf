/**
 * # E2E Secured Artifact Registry
 *
 * This example demonstrates a hardened Artifact Registry repository with:
 * - Vulnerability Scanning (Container Analysis API)
 * - Tag Immutability (Prevent overwriting production tags)
 * - Automated Cleanup Policies (Cost & Security management)
 */

# 1. Enable Security Scanning APIs
resource "google_project_service" "container_scanning" {
  project            = var.project_id
  service            = "containerscanning.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_analysis" {
  project            = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

# 2. Hardened Artifact Registry
module "registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
  description   = "Production-grade hardened Docker repository"

  # Security: Prevent overwriting existing tags
  docker_immutable_tags = true

  # Governance: Automated cleanup of old/untagged images
  cleanup_policy_dry_run = false
  cleanup_policies = {
    "delete-untagged" = {
      action = "DELETE"
      condition = {
        tag_state  = "UNTAGGED"
        older_than = "14d"
      }
    }
    "keep-recent-versions" = {
      action = "KEEP"
      most_recent_versions = {
        keep_count = 5
      }
    }
  }

  labels = var.default_labels

  # Ensure APIs are enabled before creating the repository
  depends_on = [
    google_project_service.container_scanning,
    google_project_service.container_analysis
  ]
}

# 3. Outputs
output "repository_url" {
  description = "The URL of the created repository."
  value       = module.registry.repository_url
}
