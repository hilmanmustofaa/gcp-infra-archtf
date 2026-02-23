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

data "google_project" "project" {
  project_id = var.project_id
}

# ------------------------------------------------------------------------------
# VPC and Private Service Access (PSA)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/net-vpc"

  networks = {
    "data-vpc" = {
      project                 = var.project_id
      name                    = "data-vpc"
      auto_create_subnetworks = false
    }
  }

  subnetworks = {
    "data-subnet" = {
      project       = var.project_id
      name          = "data-subnet"
      network       = "data-vpc"
      region        = var.region
      ip_cidr_range = "10.10.0.0/24"
    }
  }

  compute_routes = {}
}

# PSA: Reserved Range for Google Services (Cloud SQL)
resource "google_compute_global_address" "psa_range" {
  project       = var.project_id
  name          = "google-services-psa"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.networks["data-vpc"].id
}

# PSA: Service Networking Connection
resource "google_service_networking_connection" "psa_connection" {
  network                 = module.vpc.networks["data-vpc"].id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range.name]
}

# ------------------------------------------------------------------------------
# KMS - Centralized Keys
# ------------------------------------------------------------------------------
module "kms" {
  source = "../../modules/kms"

  kms_key_rings = {
    "data-keyring" = {
      name     = "data-keyring"
      location = var.region
      project  = var.project_id
    }
  }

  kms_crypto_keys = {
    "storage-key" = {
      name            = "storage-key"
      key_ring        = module.kms.key_rings["data-keyring"].id
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s" # 90 days
      labels          = var.default_labels
    }
    "db-key" = {
      name            = "db-key"
      key_ring        = module.kms.key_rings["data-keyring"].id
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s"
      labels          = var.default_labels
    }
  }
}

# ------------------------------------------------------------------------------
# Custom Service Account for Data Workloads
# ------------------------------------------------------------------------------
module "data_sa" {
  source = "../../modules/iam-service-accounts"

  project_id   = var.project_id
  account_id   = "data-app-sa"
  display_name = "Service Account for Data Analytics Workloads"

  # Assign roles at project level
  project_iam_bindings = {
    "logging" = {
      role = "roles/logging.logWriter"
    }
    "monitoring" = {
      role = "roles/monitoring.metricWriter"
    }
  }

  labels = var.default_labels
}

# ------------------------------------------------------------------------------
# GCS Storage (KMS-Secured)
# ------------------------------------------------------------------------------
module "gcs" {
  source = "../../modules/gcs"

  project_id = var.project_id

  storage_buckets = {
    "raw-data-bucket" = {
      name     = "raw-data-${var.project_id}"
      location = var.region

      encryption = {
        kms_key_name = module.kms.crypto_keys["storage-key"].id
      }

      lifecycle_rules = {
        "archive" = {
          action    = { type = "SET_STORAGE_CLASS", storage_class = "NEARLINE" }
          condition = { age = 30 }
        }
      }
    }
  }

  default_labels = var.default_labels
}

# Grant SA access to GCS
resource "google_storage_bucket_iam_member" "sa_storage_access" {
  bucket = module.gcs.buckets["raw-data-bucket"].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.data_sa.email}"
}

# Grant Storage Service Agent access to KMS key
resource "google_project_service_identity" "storage_agent" {
  provider = google-beta
  project  = var.project_id
  service  = "storage.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "storage_kms" {
  crypto_key_id = module.kms.crypto_keys["storage-key"].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.storage_agent.email}"
}

# ------------------------------------------------------------------------------
# Cloud SQL (Private IP + KMS)
# ------------------------------------------------------------------------------
module "sql" {
  source = "../../modules/cloudsql-instance"

  network_lookup = {
    "data-vpc" = module.vpc.networks["data-vpc"]
  }

  sql_database_instances = {
    "data-db" = {
      name             = "data-db-instance"
      region           = var.region
      database_version = "POSTGRES_15"
      project          = var.project_id

      encryption_key_name = module.kms.crypto_keys["db-key"].id

      settings = {
        tier = "db-f1-micro"

        ip_configuration = {
          ipv4_enabled        = false
          private_network     = module.vpc.networks["data-vpc"].id
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

  sql_users = {
    "app-user" = {
      name     = "app_user"
      instance = "data-db"
      password = var.db_password
      project  = var.project_id
    }
  }

  # Ensure PSA is ready before creating SQL instance
  depends_on = [google_service_networking_connection.psa_connection]

  default_labels = var.default_labels
}

# Grant SQL Service Agent access to KMS key
resource "google_project_service_identity" "sql_agent" {
  provider = google-beta
  project  = var.project_id
  service  = "sqladmin.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "sql_kms" {
  crypto_key_id = module.kms.crypto_keys["db-key"].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"
}

# ------------------------------------------------------------------------------
# Artifact Registry (AI/App Images - KMS-Secured)
# ------------------------------------------------------------------------------
module "registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  location      = var.region
  repository_id = "data-models-repo"
  format        = "DOCKER"
  description   = "Repo for data processing and AI model images"

  kms_key_name = module.kms.crypto_keys["storage-key"].id # Reusing storage key

  labels = var.default_labels
}
