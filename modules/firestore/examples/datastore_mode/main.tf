terraform {
  required_version = ">= 1.10.2"

  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = ">= 6.50.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = "us-central1"
}

variable "project_id" {
  description = "The ID of the project."
  type        = string
}

module "datastore" {
  source = "../../"

  project_id = var.project_id

  database = {
    name        = "my-datastore-db"
    location_id = "us-east1"
    type        = "DATASTORE_MODE"
  }

  indexes = {
    "task-index" = {
      collection = "Task"
      fields = [
        {
          field_path = "created"
          order      = "ASCENDING"
        },
        {
          field_path = "priority"
          order      = "DESCENDING"
        }
      ]
    }
  }
}
