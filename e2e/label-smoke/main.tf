# ============================================================================
# E2E Scenario: label-smoke
# ----------------------------------------------------------------------------
# Real apply blueprint (project: toylabs). Verifies the FinOps label-value
# hyphenation fix: modules that previously emitted dotted label values
# (rejected by GCP at apply time) now apply cleanly. A successful apply IS the
# assertion — dotted values would fail with "Invalid ... label".
#
# Covers artifact-registry (a dependency-free affected module). Together with
# the gcs e2e this proves the hyphenation fix across two GCP services; the
# heavier affected modules (gke-*, cloudsql-instance, net-lb, cloud-run-v2, dns)
# share the identical label pattern and the same fix.
# (dns is omitted here because Cloud DNS API is not enabled in the test project;
# enabling/disabling APIs inside an ephemeral e2e is intentionally avoided.)
#
# Destroy strategy: applied then destroyed by `task e2e:toylabs`. Run-scoped
# random suffix + env=e2e-toylabs labels; gitignored local state.
# ============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.13.9, < 7.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

variable "project_id" {
  description = "Target project for the e2e apply."
  type        = string
  default     = "toylabs"
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast2"
}

resource "random_id" "suffix" {
  byte_length = 3
}

# Affected module #1: artifact-registry (was artifactregistry.googleapis.com/*).
module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  location      = "asia-southeast2"
  repository_id = "e2e-labelsmoke-${random_id.suffix.hex}"
  format        = "DOCKER"

  labels = {
    env = "e2e-toylabs"
  }
}
