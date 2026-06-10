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

  project_id = var.project_id

  # Destinations must already exist (use the gcs / a bq-dataset / a pubsub-topic
  # module to create them, then reference here).
  sinks = {
    audit_to_bq = {
      name             = "audit-to-bq"
      destination_type = "bigquery"
      destination      = "audit_logs"
      filter           = "logName:\"cloudaudit.googleapis.com\""
    }

    archive_to_gcs = {
      name             = "archive-to-gcs"
      destination_type = "gcs"
      destination      = "central-log-archive"
    }
  }
}
