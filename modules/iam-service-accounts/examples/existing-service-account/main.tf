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
  description = "Project id where service account exists."
  type        = string
}

module "existing_service_account" {
  source = "../../"

  project_id = var.project_id
  account_id = "existing-sa-id"

  # Jangan create, pakai data source.
  service_account_create = false
  generate_key           = false

  display_name = "Ignored when service_account_create = false."
  description  = null
  disabled     = false
  prefix       = ""

  iam_bindings = {
    existing-sa-iam = {
      role = "roles/iam.serviceAccountUser"
      members = [
        "group:devs@example.com",
      ]
    }
  }

  iam_bindings_additive       = {}
  project_iam_bindings        = {}
  storage_bucket_iam_bindings = {}

  labels = {
    environment = "prod"
    application = "external-app"
  }
}
