# Autoscaler Outputs
output "autoscaler_id" {
  description = "The identifier of the autoscaler."
  value = try(
    google_compute_autoscaler.autoscaler[0].id,
    google_compute_region_autoscaler.autoscaler[0].id,
    null
  )
}

output "autoscaler_self_link" {
  description = "The self-link of the autoscaler."
  value = try(
    google_compute_autoscaler.autoscaler[0].self_link,
    google_compute_region_autoscaler.autoscaler[0].self_link,
    null
  )
}

# Health Check Outputs
output "health_check_id" {
  description = "The identifier of the health check."
  value       = try(google_compute_health_check.health_checks[0].id, null)
}

output "health_check_self_link" {
  description = "The self-link of the health check."
  value       = try(google_compute_health_check.health_checks[0].self_link, null)
}

# Instance Group Manager Outputs
output "instance_group" {
  description = "The instance group URL of the managed instance group."
  value = try(
    google_compute_instance_group_manager.mig[0].instance_group,
    google_compute_region_instance_group_manager.mig[0].instance_group,
    null
  )
}

output "name" {
  description = "The name of the managed instance group."
  value = try(
    google_compute_instance_group_manager.mig[0].name,
    google_compute_region_instance_group_manager.mig[0].name,
    null
  )
}

output "self_link" {
  description = "The self-link of the managed instance group."
  value = try(
    google_compute_instance_group_manager.mig[0].self_link,
    google_compute_region_instance_group_manager.mig[0].self_link,
    null
  )
}

# Stateful Configuration Outputs
output "stateful_configs" {
  description = "Map of stateful configuration details."
  value = {
    zonal = {
      for k, v in google_compute_per_instance_config.instances :
      k => {
        name      = v.name
        self_link = v.self_link
      }
    }
    regional = {
      for k, v in google_compute_region_per_instance_config.instances :
      k => {
        name      = v.name
        self_link = v.self_link
      }
    }
  }
}

# Operation Status Outputs
output "status" {
  description = "Status of the managed instance group."
  value = {
    is_stable = try(
      google_compute_instance_group_manager.mig[0].status[0].is_stable,
      google_compute_region_instance_group_manager.mig[0].status[0].is_stable,
      null
    )
    version_target = try(
      google_compute_instance_group_manager.mig[0].status[0].version_target,
      google_compute_region_instance_group_manager.mig[0].status[0].version_target,
      null
    )
    stateful = try(
      google_compute_instance_group_manager.mig[0].status[0].stateful,
      google_compute_region_instance_group_manager.mig[0].status[0].stateful,
      null
    )
  }
}
