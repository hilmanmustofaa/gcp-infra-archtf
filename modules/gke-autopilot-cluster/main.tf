locals {
  cluster_name = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, var.name]) : var.name

  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "container.googleapis.com/Cluster"
    gcp_service    = "container.googleapis.com"
    tf_module      = "gke-autopilot-cluster"
    tf_layer       = "compute"
    tf_resource    = "cluster"
  }
}

resource "google_container_cluster" "autopilot_cluster" {
  provider = google-beta
  project  = var.project_id
  name     = local.cluster_name
  location = var.location

  description        = var.description
  min_master_version = var.min_master_version
  network            = var.network
  subnetwork         = var.subnetwork

  # Autopilot mode
  enable_autopilot = true

  release_channel {
    channel = var.release_channel
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  node_config {
    service_account = var.node_service_account
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }


  dynamic "workload_identity_config" {
    for_each = var.workload_pool != null ? [1] : []
    content {
      workload_pool = var.workload_pool
    }
  }

  dynamic "gateway_api_config" {
    for_each = var.gateway_api_channel != null ? [1] : []
    content {
      channel = var.gateway_api_channel
    }
  }

  dynamic "database_encryption" {
    for_each = var.database_encryption != null ? [var.database_encryption] : []
    content {
      state    = database_encryption.value.state
      key_name = database_encryption.value.key_name
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  dynamic "maintenance_policy" {
    for_each = var.maintenance_window_start_time != null ? [1] : []
    content {
      daily_maintenance_window {
        start_time = var.maintenance_window_start_time
      }
    }
  }

  resource_labels = merge(
    local.finops_labels_default,
    var.default_labels,
    {
      "resourcetype" = "gke-autopilot-cluster"
    }
  )

  lifecycle {
    ignore_changes = [
      resource_labels["asmv"],
      resource_labels["mesh_id"]
    ]
  }
}
