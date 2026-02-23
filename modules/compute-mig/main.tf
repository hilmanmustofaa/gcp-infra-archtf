locals {
  # Determine if location is regional (e.g., us-central1) or zonal (e.g., us-central1-a)
  is_regional = length(split("-", var.location)) == 2

  # Use explicitly passed health check or fallback to created one
  health_check = (
    try(var.auto_healing_policies.health_check, null) == null
    ? try(google_compute_health_check.health_checks[0].self_link, null)
    : try(var.auto_healing_policies.health_check, null)
  )
}

# Zonal Instance Group Manager
resource "google_compute_instance_group_manager" "mig" {
  provider = google-beta
  count    = local.is_regional ? 0 : 1

  name               = var.name
  base_instance_name = var.name
  description        = var.description
  zone               = var.location
  project            = var.project_id

  target_size  = var.target_size
  target_pools = var.target_pools

  version {
    instance_template = var.instance_template
    name              = var.default_version_name
  }

  dynamic "version" {
    for_each = var.versions
    content {
      name              = version.key
      instance_template = version.value.instance_template

      dynamic "target_size" {
        for_each = version.value.target_size == null ? [] : ["dummy"]
        content {
          fixed   = version.value.target_size.fixed
          percent = version.value.target_size.percent
        }
      }
    }
  }

  dynamic "named_port" {
    for_each = var.named_ports == null ? {} : var.named_ports
    content {
      name = named_port.key
      port = named_port.value
    }
  }

  dynamic "auto_healing_policies" {
    for_each = var.auto_healing_policies == null ? [] : ["dummy"]
    content {
      health_check      = local.health_check
      initial_delay_sec = var.auto_healing_policies.initial_delay_sec
    }
  }

  dynamic "update_policy" {
    for_each = var.update_policy == null ? [] : [var.update_policy]
    content {
      minimal_action                 = update_policy.value.minimal_action
      type                           = update_policy.value.type
      max_surge_fixed                = try(update_policy.value.max_surge.fixed, null)
      max_surge_percent              = try(update_policy.value.max_surge.percent, null)
      max_unavailable_fixed          = try(update_policy.value.max_unavailable.fixed, null)
      max_unavailable_percent        = try(update_policy.value.max_unavailable.percent, null)
      min_ready_sec                  = update_policy.value.min_ready_sec
      replacement_method             = update_policy.value.replacement_method
      most_disruptive_allowed_action = update_policy.value.most_disruptive_action
    }
  }

  dynamic "stateful_disk" {
    for_each = var.stateful_disks
    content {
      device_name = stateful_disk.key
      delete_rule = stateful_disk.value ? "ON_PERMANENT_INSTANCE_DELETION" : "NEVER"
    }
  }

  wait_for_instances        = try(var.wait_for_instances.enabled, null)
  wait_for_instances_status = try(var.wait_for_instances.status, null)
}

# Regional Instance Group Manager
resource "google_compute_region_instance_group_manager" "mig" {
  provider = google-beta
  count    = local.is_regional ? 1 : 0

  name               = var.name
  base_instance_name = var.name
  description        = var.description
  region             = var.location
  project            = var.project_id

  target_size  = var.target_size
  target_pools = var.target_pools

  distribution_policy_target_shape = try(var.distribution_policy.target_shape, null)
  distribution_policy_zones        = try(var.distribution_policy.zones, null)

  version {
    instance_template = var.instance_template
    name              = var.default_version_name
  }

  dynamic "version" {
    for_each = var.versions
    content {
      name              = version.key
      instance_template = version.value.instance_template

      dynamic "target_size" {
        for_each = version.value.target_size == null ? [] : ["dummy"]
        content {
          fixed   = version.value.target_size.fixed
          percent = version.value.target_size.percent
        }
      }
    }
  }

  dynamic "named_port" {
    for_each = var.named_ports == null ? {} : var.named_ports
    content {
      name = named_port.key
      port = named_port.value
    }
  }

  dynamic "auto_healing_policies" {
    for_each = var.auto_healing_policies == null ? [] : ["dummy"]
    content {
      health_check      = local.health_check
      initial_delay_sec = var.auto_healing_policies.initial_delay_sec
    }
  }

  dynamic "update_policy" {
    for_each = var.update_policy == null ? [] : [var.update_policy]
    content {
      minimal_action                 = update_policy.value.minimal_action
      type                           = update_policy.value.type
      max_surge_fixed                = try(update_policy.value.max_surge.fixed, null)
      max_surge_percent              = try(update_policy.value.max_surge.percent, null)
      max_unavailable_fixed          = try(update_policy.value.max_unavailable.fixed, null)
      max_unavailable_percent        = try(update_policy.value.max_unavailable.percent, null)
      min_ready_sec                  = update_policy.value.min_ready_sec
      replacement_method             = update_policy.value.replacement_method
      most_disruptive_allowed_action = update_policy.value.most_disruptive_action
      instance_redistribution_type   = update_policy.value.regional_redistribution_type
    }
  }

  dynamic "stateful_disk" {
    for_each = var.stateful_disks
    content {
      device_name = stateful_disk.key
      delete_rule = stateful_disk.value ? "ON_PERMANENT_INSTANCE_DELETION" : "NEVER"
    }
  }

  wait_for_instances        = try(var.wait_for_instances.enabled, null)
  wait_for_instances_status = try(var.wait_for_instances.status, null)
}

# Unmanaged Instance Groups
resource "google_compute_instance_group" "compute_instance_groups" {
  provider = google
  for_each = var.compute_instance_groups

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  description = each.value.description
  zone        = each.value.zone
  network     = each.value.network
  instances   = each.value.instances

  dynamic "named_port" {
    for_each = each.value.named_port
    content {
      name = named_port.key
      port = named_port.value
    }
  }

  project = each.value.project
}
