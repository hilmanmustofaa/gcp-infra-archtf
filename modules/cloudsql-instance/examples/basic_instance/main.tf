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

module "basic_instance" {
  source = "../../"

  resource_prefix = "example"
  default_labels = {
    env = "dev"
  }

  sql_database_instances = {
    "pg-instance" = {
      name             = "pg-instance"
      region           = "us-central1"
      database_version = "POSTGRES_14"
      project          = var.project_id
      settings = {
        tier                    = "db-f1-micro"
        database_flags          = []
        active_directory_config = []
        backup_configuration = {
          enabled = true
          backup_retention_settings = {
            retained_backups = 7
            retention_unit   = "COUNT"
          }
        }
        ip_configuration = {
          ipv4_enabled        = true
          authorized_networks = {}
        }
        location_preference = {}
        maintenance_window  = {}
        insights_config     = {}
      }
    }
  }
}
