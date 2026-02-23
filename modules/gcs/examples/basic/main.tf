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
  description = "The ID of the project where the buckets will be created."
  type        = string
}

module "gcs_basic" {
  source = "../../"

  project_id      = var.project_id
  resource_prefix = "demo"
  join_separator  = "-"

  default_labels = {
    environment = "dev"
    team        = "platform"
  }

  storage_buckets = {
    main = {
      name     = "app-data"
      location = "ASIA-SOUTHEAST2"

      labels                      = {}
      force_destroy               = false
      uniform_bucket_level_access = true
      public_access_prevention    = "inherited"
      storage_class               = "STANDARD"

      versioning = {
        enabled = false
      }

      autoclass               = null
      lifecycle_rules         = null
      retention_policy        = {}
      logging                 = {}
      website                 = null
      custom_placement_config = null
    }
  }

  objects = {}
}
