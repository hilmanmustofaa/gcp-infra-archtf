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
  description = "Project id where service account will be created."
  type        = string
}

variable "logs_bucket" {
  description = "Logs bucket name for storage IAM bindings."
  type        = string
}

module "service_account_full_iam" {
  source = "../../"

  project_id = var.project_id
  account_id = "app-full-iam-sa"

  display_name = "SA with project and bucket IAM."
  description  = "Service account with project-level and bucket-level IAM."
  disabled     = false
  prefix       = ""

  service_account_create = true
  generate_key           = false

  iam_bindings = {
    token-creator = {
      role = "roles/iam.serviceAccountTokenCreator"
      members = [
        "group:app-runners@example.com",
      ]
    }
  }

  iam_bindings_additive = {
    logs-writer = {
      role   = "roles/logging.logWriter"
      member = "group:logging@example.com"
    }
  }

  project_iam_bindings = {
    proj-viewer = {
      role = "roles/viewer"
    }
  }

  storage_bucket_iam_bindings = {
    logs-bucket = {
      bucket = var.logs_bucket
      role   = "roles/storage.objectCreator"
    }
  }

  labels = {
    environment = "prod"
    application = "backend-api"
    cost_center = "cc-1234"
    owner_team  = "platform"
  }
}
