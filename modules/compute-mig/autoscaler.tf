locals {
  as_scaling = try(var.autoscaler_config.scaling_control, null)
  as_signals = try(var.autoscaler_config.scaling_signals, null)
}

# Zonal Autoscaler
resource "google_compute_autoscaler" "autoscaler" {
  provider = google-beta
  count    = local.is_regional || var.autoscaler_config == null ? 0 : 1

  project     = var.project_id
  name        = var.name
  zone        = var.location
  description = var.description
  target      = google_compute_instance_group_manager.mig[0].id

  autoscaling_policy {
    max_replicas    = var.autoscaler_config.max_replicas
    min_replicas    = var.autoscaler_config.min_replicas
    cooldown_period = var.autoscaler_config.cooldown_period
    mode            = var.autoscaler_config.mode

    dynamic "scale_down_control" {
      for_each = local.as_scaling.down == null ? [] : [local.as_scaling.down]
      content {
        time_window_sec = scale_down_control.value.time_window_sec
        dynamic "max_scaled_down_replicas" {
          for_each = (
            scale_down_control.value.max_replicas_fixed == null &&
            scale_down_control.value.max_replicas_percent == null
          ) ? [] : [scale_down_control.value]
          content {
            fixed   = scale_down_control.value.max_replicas_fixed
            percent = scale_down_control.value.max_replicas_percent
          }
        }
      }
    }

    dynamic "scale_in_control" {
      for_each = local.as_scaling.in == null ? [] : [local.as_scaling.in]
      content {
        time_window_sec = scale_in_control.value.time_window_sec
        dynamic "max_scaled_in_replicas" {
          for_each = (
            scale_in_control.value.max_replicas_fixed == null &&
            scale_in_control.value.max_replicas_percent == null
          ) ? [] : [scale_in_control.value]
          content {
            fixed   = scale_in_control.value.max_replicas_fixed
            percent = scale_in_control.value.max_replicas_percent
          }
        }
      }
    }

    dynamic "cpu_utilization" {
      for_each = local.as_signals.cpu_utilization == null ? [] : [local.as_signals.cpu_utilization]
      content {
        target = cpu_utilization.value.target
        predictive_method = (
          cpu_utilization.value.optimize_availability == true
          ? "OPTIMIZE_AVAILABILITY"
          : null
        )
      }
    }

    dynamic "load_balancing_utilization" {
      for_each = local.as_signals.load_balancing_utilization == null ? [] : [local.as_signals.load_balancing_utilization]
      content {
        target = load_balancing_utilization.value.target
      }
    }

    dynamic "metric" {
      for_each = local.as_signals.metrics == null ? [] : local.as_signals.metrics
      content {
        name                       = metric.value.name
        type                       = metric.value.type
        target                     = metric.value.target_value
        single_instance_assignment = metric.value.single_instance_assignment
        filter                     = metric.value.time_series_filter
      }
    }

    dynamic "scaling_schedules" {
      for_each = local.as_signals.schedules == null ? [] : local.as_signals.schedules
      iterator = schedule
      content {
        duration_sec          = schedule.value.duration_sec
        min_required_replicas = schedule.value.min_required_replicas
        name                  = schedule.value.name
        schedule              = schedule.value.cron_schedule
        description           = schedule.value.description
        disabled              = schedule.value.disabled
        time_zone             = schedule.value.timezone
      }
    }
  }
}

# Regional Autoscaler
resource "google_compute_region_autoscaler" "autoscaler" {
  provider = google-beta
  count    = local.is_regional && var.autoscaler_config != null ? 1 : 0

  project     = var.project_id
  name        = var.name
  region      = var.location
  description = var.description
  target      = google_compute_region_instance_group_manager.mig[0].id

  autoscaling_policy {
    max_replicas    = var.autoscaler_config.max_replicas
    min_replicas    = var.autoscaler_config.min_replicas
    cooldown_period = var.autoscaler_config.cooldown_period
    mode            = var.autoscaler_config.mode

    dynamic "scale_down_control" {
      for_each = local.as_scaling.down == null ? [] : [local.as_scaling.down]
      content {
        time_window_sec = scale_down_control.value.time_window_sec
        dynamic "max_scaled_down_replicas" {
          for_each = (
            scale_down_control.value.max_replicas_fixed == null &&
            scale_down_control.value.max_replicas_percent == null
          ) ? [] : [scale_down_control.value]
          content {
            fixed   = scale_down_control.value.max_replicas_fixed
            percent = scale_down_control.value.max_replicas_percent
          }
        }
      }
    }

    dynamic "scale_in_control" {
      for_each = local.as_scaling.in == null ? [] : [local.as_scaling.in]
      content {
        time_window_sec = scale_in_control.value.time_window_sec
        dynamic "max_scaled_in_replicas" {
          for_each = (
            scale_in_control.value.max_replicas_fixed == null &&
            scale_in_control.value.max_replicas_percent == null
          ) ? [] : [scale_in_control.value]
          content {
            fixed   = scale_in_control.value.max_replicas_fixed
            percent = scale_in_control.value.max_replicas_percent
          }
        }
      }
    }

    dynamic "cpu_utilization" {
      for_each = local.as_signals.cpu_utilization == null ? [] : [local.as_signals.cpu_utilization]
      content {
        target = cpu_utilization.value.target
        predictive_method = (
          cpu_utilization.value.optimize_availability == true
          ? "OPTIMIZE_AVAILABILITY"
          : null
        )
      }
    }

    dynamic "load_balancing_utilization" {
      for_each = local.as_signals.load_balancing_utilization == null ? [] : [local.as_signals.load_balancing_utilization]
      content {
        target = load_balancing_utilization.value.target
      }
    }

    dynamic "metric" {
      for_each = local.as_signals.metrics == null ? [] : local.as_signals.metrics
      content {
        name                       = metric.value.name
        type                       = metric.value.type
        target                     = metric.value.target_value
        single_instance_assignment = metric.value.single_instance_assignment
        filter                     = metric.value.time_series_filter
      }
    }

    dynamic "scaling_schedules" {
      for_each = local.as_signals.schedules == null ? [] : local.as_signals.schedules
      iterator = schedule
      content {
        duration_sec          = schedule.value.duration_sec
        min_required_replicas = schedule.value.min_required_replicas
        name                  = schedule.value.name
        schedule              = schedule.value.cron_schedule
        description           = schedule.value.description
        disabled              = schedule.value.disabled
        time_zone             = schedule.value.timezone
      }
    }
  }
}
