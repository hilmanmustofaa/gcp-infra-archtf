terraform {
  required_version = ">= 1.10.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.50.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast2"
}

variable "project_id" {
  description = "The project ID to deploy resources into."
  type        = string
}

module "this" {
  source = "../../"

  project_id      = var.project_id
  resource_prefix = "demo"

  default_labels = {
    env     = "dev"
    project = "demo"
    owner   = "platform"
  }

  datasets = {
    # Audit-trail dataset (pairs with the logging-sink module's bigquery sink).
    audit = {
      dataset_id                  = "audit_logs"
      description                 = "Centralized audit log export"
      location                    = "asia-southeast2"
      default_partition_expiration_ms = 31536000000 # 365 days
      iam_members = {
        viewer = {
          role   = "roles/bigquery.dataViewer"
          member = "group:security@example.com"
        }
      }
    }
  }
}
