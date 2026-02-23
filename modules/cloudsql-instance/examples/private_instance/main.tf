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

# Create a VPC for private access
resource "google_compute_network" "vpc" {
  name                    = "sql-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

module "private_instance" {
  source = "../../"

  resource_prefix = "private"

  # Pass network lookup for private IP configuration
  network_lookup = {
    "sql-vpc" = google_compute_network.vpc
  }

  sql_database_instances = {
    "mysql-instance" = {
      name             = "mysql-instance"
      region           = "us-central1"
      database_version = "MYSQL_8_0"
      project          = var.project_id
      settings = {
        tier                    = "db-n1-standard-1"
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
          ipv4_enabled        = false
          private_network     = "sql-vpc"
          authorized_networks = {}
        }
        location_preference = {}
        maintenance_window  = {}
        insights_config     = {}
      }
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}
