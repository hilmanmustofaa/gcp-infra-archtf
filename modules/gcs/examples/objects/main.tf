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

module "gcs_objects" {
  source = "../../"

  project_id      = var.project_id
  resource_prefix = null
  join_separator  = "-"

  default_labels = {
    environment = "test"
    application = "demo-gcs"
  }

  storage_buckets = {
    main = {
      name     = "demo-objects-bucket"
      location = "US"

      labels                      = {}
      force_destroy               = true
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

  objects = {
    config = {
      bucket              = "main" # key in storage_buckets
      name                = "config.json"
      metadata            = null
      content             = "{}"
      source              = null
      cache_control       = null
      content_disposition = null
      content_encoding    = null
      content_language    = null
      content_type        = "application/json"
      storage_class       = null
      customer_encryption = null
    }
  }
}
