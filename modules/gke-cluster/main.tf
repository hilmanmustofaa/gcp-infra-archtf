locals {
  cluster_name = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, var.name]) : var.name
  location     = var.location != null ? var.location : (var.node_locations != null && length(var.node_locations) > 0 ? var.node_locations[0] : null)

  default_nodepool = {
    initial_node_count = 1
    remove_pool        = true
  }

  addons_config = {
    horizontal_pod_autoscaling = {
      disabled = !try(var.enable_addons.horizontal_pod_autoscaling, true)
    }
    http_load_balancing = {
      disabled = !try(var.enable_addons.http_load_balancing, true)
    }
    network_policy_config = {
      disabled = !try(var.enable_addons.network_policy, false)
    }
    cloudrun_config = {
      disabled           = !try(var.enable_addons.cloudrun, false)
      load_balancer_type = try(var.enable_addons.cloudrun_load_balancer_type, "EXTERNAL")
    }
    istio_config = {
      disabled = var.enable_addons.istio == null
      auth     = try(var.enable_addons.istio.enable_tls, false) ? "AUTH_MUTUAL_TLS" : "AUTH_NONE"
    }
  }

  registry_config = {
    enabled    = var.enable_private_registry
    fqdns      = var.certificate_authority_fqdns
    secret_uri = var.certificate_authority_secret_uri
  }

  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "container.googleapis.com/Cluster"
    gcp_service    = "container.googleapis.com"
    tf_module      = "gke-cluster"
    tf_layer       = "compute"
    tf_resource    = "cluster"
  }
}

resource "google_container_cluster" "container_clusters" {
  provider = google-beta
  project  = var.project_id
  name     = local.cluster_name
  location = local.location

  description               = var.description
  min_master_version        = var.min_master_version
  default_max_pods_per_node = var.default_max_pods_per_node
  network                   = var.network
  subnetwork                = var.subnetwork
  initial_node_count        = local.default_nodepool.initial_node_count
  remove_default_node_pool  = local.default_nodepool.remove_pool
  node_locations            = length(var.node_locations) > 0 ? var.node_locations : null

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

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  enable_shielded_nodes   = var.enable_shielded_nodes
  enable_legacy_abac      = var.enable_legacy_abac
  enable_tpu              = var.enable_tpu
  enable_kubernetes_alpha = var.enable_kubernetes_alpha

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

  addons_config {
    horizontal_pod_autoscaling {
      disabled = local.addons_config.horizontal_pod_autoscaling.disabled
    }
    http_load_balancing {
      disabled = local.addons_config.http_load_balancing.disabled
    }
    network_policy_config {
      disabled = local.addons_config.network_policy_config.disabled
    }
    dynamic "cloudrun_config" {
      for_each = try(var.enable_addons.cloudrun, false) ? [1] : []
      content {
        disabled           = local.addons_config.cloudrun_config.disabled
        load_balancer_type = "LOAD_BALANCER_TYPE_INTERNAL"
      }
    }
    dynamic "istio_config" {
      for_each = var.enable_addons.istio != null ? [1] : []
      content {
        disabled = local.addons_config.istio_config.disabled
        auth     = local.addons_config.istio_config.auth
      }
    }
  }

  database_encryption {
    state    = var.database_encryption.state
    key_name = var.database_encryption.key_name
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


  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      var.enable_workload_logs ? "WORKLOADS" : null
    ]
  }

  monitoring_config {
    enable_components = var.monitoring_components
  }

  dynamic "notification_config" {
    for_each = var.upgrade_notifications != null ? [""] : []
    content {
      pubsub {
        enabled = true
        topic = try(
          var.upgrade_notifications.topic_id,
          google_pubsub_topic.notifications[0].id
        )
      }
    }
  }

  resource_labels = merge(
    local.finops_labels_default,
    var.default_labels,
    {
      "resourcetype" = "gke-cluster"
    }
  )


  lifecycle {
    ignore_changes = [
      node_pool,
      initial_node_count,
      resource_labels["asmv"],
      resource_labels["mesh_id"]
    ]
  }
}

resource "google_gke_backup_backup_plan" "backup_plan" {
  for_each = (
    var.enable_backup_agent && var.backup_plans != null
    ? var.backup_plans
    : {}
  )

  name     = each.key
  cluster  = google_container_cluster.container_clusters.id
  location = each.value.region
  project  = var.project_id
  labels   = each.value.labels

  retention_policy {
    backup_delete_lock_days = try(each.value.retention_policy_delete_lock_days, null)
    backup_retain_days      = try(each.value.retention_policy_days, null)
    locked                  = try(each.value.retention_policy_lock, false)
  }

  backup_schedule {
    cron_schedule = each.value.schedule
  }

  backup_config {
    include_volume_data = each.value.include_volume_data
    include_secrets     = each.value.include_secrets

    dynamic "encryption_key" {
      for_each = each.value.encryption_key != null ? [""] : []
      content {
        gcp_kms_encryption_key = each.value.encryption_key
      }
    }

    all_namespaces = (
      lookup(each.value, "namespaces", null) == null &&
      lookup(each.value, "applications", null) == null ? true : null
    )

    dynamic "selected_namespaces" {
      for_each = each.value.namespaces != null ? [""] : []
      content {
        namespaces = each.value.namespaces
      }
    }

    dynamic "selected_applications" {
      for_each = each.value.applications != null ? [""] : []
      content {
        dynamic "namespaced_names" {
          for_each = flatten([
            for ns, apps in each.value.applications : [
              for app in apps : { namespace = ns, name = app }
            ]
          ])
          content {
            namespace = namespaced_names.value.namespace
            name      = namespaced_names.value.name
          }
        }
      }
    }
  }
}

resource "google_pubsub_topic" "notifications" {
  count = (
    var.upgrade_notifications != null &&
    try(var.upgrade_notifications.topic_id, null) == null ? 1 : 0
  )

  project = var.project_id
  name    = "gke-upgrade-notifications"
  labels = {
    content = "gke-notifications"
  }
}
