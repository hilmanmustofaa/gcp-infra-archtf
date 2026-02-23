/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# ------------------------------------------------------------------------------
# 1. Networking (VPC + PSA + Connector)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/net-vpc"

  networks = {
    "serverless-vpc" = {
      project                 = var.project_id
      name                    = "serverless-vpc"
      auto_create_subnetworks = false
    }
  }

  subnetworks = {
    "serverless-subnet" = {
      project       = var.project_id
      name          = "serverless-subnet"
      network       = "serverless-vpc"
      region        = var.region
      ip_cidr_range = "10.0.1.0/24"
    }
  }

  compute_routes = {}
}

# Reserved range for PSA (Cloud SQL)
resource "google_compute_global_address" "psa_range" {
  project       = var.project_id
  name          = "serverless-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.networks["serverless-vpc"].id
}

resource "google_service_networking_connection" "psa_connection" {
  network                 = module.vpc.networks["serverless-vpc"].id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range.name]
}

# Serverless VPC Access Connector
resource "google_vpc_access_connector" "connector" {
  name          = "serverless-conn"
  project       = var.project_id
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"
  network       = module.vpc.networks["serverless-vpc"].id
}

# ------------------------------------------------------------------------------
# 2. Secret Manager
# ------------------------------------------------------------------------------
resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "db-password"

  replication {
    auto {}
  }

  labels = var.default_labels
}

# ------------------------------------------------------------------------------
# 3. Cloud SQL (Private IP)
# ------------------------------------------------------------------------------
module "sql" {
  source = "../../modules/cloudsql-instance"

  network_lookup = {
    "serverless-vpc" = module.vpc.networks["serverless-vpc"]
  }

  sql_database_instances = {
    "serverless-db" = {
      name             = "serverless-db"
      region           = var.region
      database_version = "POSTGRES_15"
      project          = var.project_id

      settings = {
        tier = "db-f1-micro"

        ip_configuration = {
          ipv4_enabled        = false
          private_network     = module.vpc.networks["serverless-vpc"].id
          authorized_networks = {}
        }

        backup_configuration = {
          enabled = true
          backup_retention_settings = {
            retained_backups = 7
            retention_unit   = "COUNT"
          }
        }

        database_flags          = []
        active_directory_config = []
        insights_config         = {}
        location_preference     = {}
        maintenance_window      = {}
      }
    }
  }

  depends_on = [google_service_networking_connection.psa_connection]

  default_labels = var.default_labels
}

# ------------------------------------------------------------------------------
# 4. Cloud Run v2 (Modern App)
# ------------------------------------------------------------------------------
module "cloud_run" {
  source = "../../modules/cloud-run-v2"

  project_id = var.project_id
  region     = var.region
  name       = "modern-app"

  # Service Identity
  service_account_create = true

  containers = {
    "main" = {
      image = var.image
      env = {
        "DB_HOST" = module.sql.instances["serverless-db"].private_ip_address
        "DB_USER" = "webapp"
      }
      # Inject secret as env var
      env_from_key = {
        "DB_PASS" = {
          secret  = google_secret_manager_secret.db_password.secret_id
          version = "latest"
        }
      }
    }
  }

  revision = {
    vpc_access = {
      connector = google_vpc_access_connector.connector.id
      egress    = "ALL_TRAFFIC"
    }
  }

  # IAM for the auto-created SA in {ROLE => [MEMBERS]} format
  iam = {
    "roles/run.invoker" = ["allUsers"]
  }

  labels = var.default_labels
}

# Grant Secret Access to Cloud Run SA
resource "google_secret_manager_secret_iam_member" "run_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.cloud_run.service_account_email}"
}

# Grant Cloud SQL Client to Cloud Run SA
resource "google_project_iam_member" "run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${module.cloud_run.service_account_email}"
}
