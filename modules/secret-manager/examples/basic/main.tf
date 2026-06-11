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
  join_separator  = "-"

  default_labels = {
    env     = "dev"
    project = "demo"
    owner   = "platform"
  }

  secrets = {
    # Automatic replication (standard client).
    api_key = {
      secret_id = "api-key"
      replication = {
        automatic = true
      }
      iam_bindings = {
        app_access = {
          role    = "roles/secretmanager.secretAccessor"
          members = ["serviceAccount:app@${var.project_id}.iam.gserviceaccount.com"]
        }
      }
    }

    # User-managed replication pinned to Jakarta with CMEK + 90-day rotation
    # (banking / government residency).
    db_password = {
      secret_id = "db-password"
      replication = {
        user_managed_replicas = [
          {
            location     = "asia-southeast2"
            kms_key_name = "projects/${var.project_id}/locations/asia-southeast2/keyRings/sm/cryptoKeys/sm-key"
          }
        ]
      }
      rotation = {
        rotation_period    = "7776000s"
        next_rotation_time = "2026-09-01T00:00:00Z"
      }
      topics = ["projects/${var.project_id}/topics/secret-rotation"]
    }
  }
}
