# ============================================================================
# E2E Scenario: bq-dataset
# ----------------------------------------------------------------------------
# Real apply blueprint (project: toylabs). Creates a BigQuery dataset with
# expirations + additive IAM + FinOps labels via the bq-dataset module, then
# tears it down. Validates the BigQuery destination story used by logging-sink.
#
# Destroy strategy: applied then destroyed by `task e2e:toylabs`.
# delete_contents_on_destroy = true so the dataset tears down cleanly.
# Run-scoped random_id suffix keeps dataset ids unique across runs.
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

data "google_project" "this" {
  project_id = var.project_id
}

locals {
  labels = {
    env     = "e2e-toylabs"
    project = "module-library"
    owner   = "ci"
  }
  # Impersonal, always-valid principal for the IAM smoke test (default compute SA).
  test_member = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}

module "bq" {
  source = "../../modules/bq-dataset"

  project_id     = var.project_id
  default_labels = local.labels

  datasets = {
    audit = {
      dataset_id                      = "e2e_audit_${random_id.suffix.hex}"
      description                     = "E2E audit dataset (auto-destroyed)"
      location                        = "asia-southeast2"
      default_partition_expiration_ms = 2592000000 # 30 days
      delete_contents_on_destroy      = true
      iam_members = {
        viewer = {
          role   = "roles/bigquery.dataViewer"
          member = local.test_member
        }
      }
    }
  }
}

output "dataset_id" {
  value = module.bq.dataset_ids["audit"]
}
