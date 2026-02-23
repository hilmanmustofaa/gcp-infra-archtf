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
# VPC and Subnets
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/net-vpc"

  networks = {
    "gke-vpc" = {
      project                 = var.project_id
      name                    = "gke-vpc"
      auto_create_subnetworks = false
    }
  }

  subnetworks = {
    "gke-subnet" = {
      project       = var.project_id
      name          = "gke-subnet"
      network       = "gke-vpc"
      region        = var.region
      ip_cidr_range = "10.0.0.0/24"
      secondary_ip_range = {
        pods = {
          range_name    = "pods"
          ip_cidr_range = "10.1.0.0/16"
        }
        services = {
          range_name    = "services"
          ip_cidr_range = "10.2.0.0/20"
        }
      }
    }
  }

  compute_routes = {}
}

# ------------------------------------------------------------------------------
# Custom Service Account for Nodes
# ------------------------------------------------------------------------------
module "node_sa" {
  source       = "../../modules/iam-service-accounts"
  project_id   = var.project_id
  account_id   = "gke-node-sa-e2e"
  display_name = "Hardened GKE Node Service Account"

  labels = var.default_labels
}

# ------------------------------------------------------------------------------
# GKE Cluster
# ------------------------------------------------------------------------------
module "gke_cluster" {
  source     = "../../modules/gke-cluster"
  project_id = var.project_id
  name       = "e2e-gke-cluster"
  location   = var.region

  network    = module.vpc.networks["gke-vpc"].self_link
  subnetwork = module.vpc.subnetworks["gke-subnet"].self_link

  cluster_secondary_range_name  = "pods"
  services_secondary_range_name = "services"

  # Security Hardening
  database_encryption = {
    state    = "ENCRYPTED"
    key_name = var.kms_key_name
  }

  node_service_account = module.node_sa.email

  # Networking
  master_authorized_networks = var.master_authorized_networks

  # FinOps
  default_labels = var.default_labels

}

# ------------------------------------------------------------------------------
# GKE Node Pools (demonstrating specialized pools)
# ------------------------------------------------------------------------------

# Application Node Pool (Standard)
module "node_pool_app" {
  source       = "../../modules/gke-nodepool"
  project_id   = var.project_id
  cluster_name = module.gke_cluster.cluster_name
  location     = var.region
  name         = "app-pool"

  node_count = {
    initial = 1
    current = 1
  }

  machine_type = "e2-standard-4"

  service_account_email = module.node_sa.email

  # Disk encryption with KMS
  boot_disk_kms_key = var.kms_key_name

  default_labels = var.default_labels
}

# Batch Node Pool (Spot instances for cost optimization)
module "node_pool_batch" {
  source       = "../../modules/gke-nodepool"
  project_id   = var.project_id
  cluster_name = module.gke_cluster.cluster_name
  location     = var.region
  name         = "batch-pool"

  node_count = {
    initial = 0
    current = 0
  }

  autoscaling = {
    min_node_count = 0
    max_node_count = 5
  }

  machine_type = "e2-medium"
  spot         = true # Use Spot instances

  service_account_email = module.node_sa.email

  taints = {
    "dedicated" = {
      value  = "batch"
      effect = "NO_SCHEDULE"
    }
  }

  default_labels = var.default_labels
}
