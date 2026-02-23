locals {
  service_account_scopes = coalesce(var.oauth_scopes, [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/userinfo.email"
  ])

  node_pool_name = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, var.name]) : var.name
  node_locations = var.node_locations != null ? var.node_locations : []

  image_type = coalesce(var.image_type, "-")
  is_cos     = length(regexall("COS", local.image_type)) > 0
  is_cos_containerd = (
    var.image_type == null || length(regexall("COS_CONTAINERD", local.image_type)) > 0
  )
  is_windows = length(regexall("WIN", local.image_type)) > 0

  taints = merge(var.taints, !local.is_windows ? {} : {
    "node.kubernetes.io/os" = {
      value  = "windows"
      effect = "NO_EXECUTE"
    }
  })
}

resource "google_container_node_pool" "container_node_pools" {
  provider = google-beta
  project  = var.project_id
  name     = local.node_pool_name
  location = var.location
  cluster  = var.cluster_name
  version  = var.node_version

  initial_node_count = var.node_count.initial
  node_count         = var.autoscaling == null ? var.node_count.current : null
  node_locations     = local.node_locations

  dynamic "autoscaling" {
    for_each = var.autoscaling != null ? [1] : []
    content {
      min_node_count       = var.autoscaling.min_node_count
      max_node_count       = var.autoscaling.max_node_count
      location_policy      = var.autoscaling.location_policy
      total_min_node_count = var.autoscaling.total_min_node_count
      total_max_node_count = var.autoscaling.total_max_node_count
    }
  }

  node_config {
    machine_type     = var.machine_type
    disk_size_gb     = var.disk_size
    disk_type        = var.disk_type
    image_type       = var.image_type
    local_ssd_count  = var.local_ssd_count
    service_account  = var.service_account_email
    oauth_scopes     = local.service_account_scopes
    min_cpu_platform = var.min_cpu_platform
    tags             = var.tags
    labels = merge(
      var.default_labels,
      var.labels,
      {
        "resourcetype" = "gke-nodepool"
      }
    )
    metadata = merge(
      var.metadata,
      { disable-legacy-endpoints = "true" }
    )
    preemptible       = var.spot == null ? var.preemptible : null
    spot              = var.spot
    boot_disk_kms_key = var.boot_disk_kms_key

    dynamic "taint" {
      for_each = local.taints
      content {
        key    = taint.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    dynamic "guest_accelerator" {
      for_each = var.guest_accelerator != null ? [1] : []
      content {
        type               = var.guest_accelerator.type
        count              = var.guest_accelerator.count
        gpu_partition_size = var.guest_accelerator.gpu_partition_size

        dynamic "gpu_driver_installation_config" {
          for_each = var.guest_accelerator.gpu_driver != null ? [1] : []
          content {
            gpu_driver_version = var.guest_accelerator.gpu_driver.version
          }
        }

        dynamic "gpu_sharing_config" {
          for_each = try(var.guest_accelerator.gpu_driver.max_shared_clients_per_gpu, null) != null ? [1] : []
          content {
            gpu_sharing_strategy       = "TIME_SHARING"
            max_shared_clients_per_gpu = var.guest_accelerator.gpu_driver.max_shared_clients_per_gpu
          }
        }
      }
    }

    dynamic "ephemeral_storage_config" {
      for_each = var.ephemeral_ssd_count != null ? [1] : []
      content {
        local_ssd_count = var.ephemeral_ssd_count
      }
    }

    dynamic "shielded_instance_config" {
      for_each = var.shielded_instance_config != null ? [1] : []
      content {
        enable_secure_boot          = var.shielded_instance_config.enable_secure_boot
        enable_integrity_monitoring = var.shielded_instance_config.enable_integrity_monitoring
      }
    }

    dynamic "sandbox_config" {
      for_each = var.sandbox_config != null ? [1] : []
      content {
        sandbox_type = var.sandbox_config.sandbox_type
      }
    }

    dynamic "linux_node_config" {
      for_each = var.linux_node_config != null ? [1] : []
      content {
        sysctls     = var.linux_node_config.sysctls
        cgroup_mode = var.linux_node_config.cgroup_mode
      }
    }

    dynamic "kubelet_config" {
      for_each = var.kubelet_config != null ? [1] : []
      content {
        cpu_manager_policy   = var.kubelet_config.cpu_manager_policy
        cpu_cfs_quota        = var.kubelet_config.cpu_cfs_quota
        cpu_cfs_quota_period = var.kubelet_config.cpu_cfs_quota_period
        pod_pids_limit       = var.kubelet_config.pod_pids_limit
      }
    }

    workload_metadata_config {
      mode = var.workload_metadata_config != null ? var.workload_metadata_config : "GKE_METADATA"
    }

    dynamic "reservation_affinity" {
      for_each = var.reservation_affinity != null ? [1] : []
      content {
        consume_reservation_type = var.reservation_affinity.consume_reservation_type
        key                      = var.reservation_affinity.key
        values                   = var.reservation_affinity.values
      }
    }

    dynamic "gvnic" {
      for_each = var.gvnic && local.is_cos ? [1] : []
      content {
        enabled = true
      }
    }

    dynamic "gcfs_config" {
      for_each = var.gcfs && local.is_cos_containerd ? [1] : []
      content {
        enabled = true
      }
    }

    dynamic "local_nvme_ssd_block_config" {
      for_each = var.local_nvme_ssd_count > 0 ? [1] : []
      content {
        local_ssd_count = var.local_nvme_ssd_count
      }
    }

    dynamic "confidential_nodes" {
      for_each = var.enable_confidential_nodes ? [1] : []
      content {
        enabled = true
      }
    }


  }

  management {
    auto_repair  = var.management != null ? var.management.auto_repair : true
    auto_upgrade = var.management != null ? var.management.auto_upgrade : true
  }

  dynamic "upgrade_settings" {
    for_each = var.upgrade_settings != null ? [1] : []
    content {
      max_surge       = var.upgrade_settings.max_surge
      max_unavailable = var.upgrade_settings.max_unavailable
      strategy        = var.upgrade_settings.strategy
      blue_green_settings {
        node_pool_soak_duration = var.upgrade_settings.node_pool_soak_duration
        standard_rollout_policy {
          batch_percentage    = var.upgrade_settings.batch_percentage
          batch_soak_duration = var.upgrade_settings.batch_soak_duration
        }
      }
    }
  }

  dynamic "placement_policy" {
    for_each = var.placement_policy != null ? [1] : []
    content {
      type         = var.placement_policy.type
      policy_name  = var.placement_policy.policy_name
      tpu_topology = var.placement_policy.tpu_topology
    }
  }

  dynamic "network_config" {
    for_each = var.network_config != null ? [1] : []
    content {
      create_pod_range     = var.network_config.create_pod_range
      enable_private_nodes = var.network_config.enable_private_nodes
      pod_ipv4_cidr_block  = var.network_config.pod_ipv4_cidr_block
      pod_range            = var.network_config.pod_range
    }
  }

  dynamic "queued_provisioning" {
    for_each = var.queued_provisioning ? [1] : []
    content {
      enabled = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      initial_node_count,
      node_count
    ]
  }

  timeouts {
    create = lookup(var.timeouts, "create", "45m")
    update = lookup(var.timeouts, "update", "45m")
    delete = lookup(var.timeouts, "delete", "45m")
  }
}
