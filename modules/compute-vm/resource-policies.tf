resource "google_compute_resource_policy" "compute_resource_policies" {
  provider = google
  for_each = var.compute_resource_policies

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  description = each.value.description
  region      = each.value.region
  project     = coalesce(each.value.project, var.project_id)

  # Snapshot Schedule Policy
  dynamic "snapshot_schedule_policy" {
    for_each = each.value.snapshot_schedule_policy != null ? [""] : []
    content {
      schedule {
        dynamic "hourly_schedule" {
          for_each = try(each.value.snapshot_schedule_policy.hourly_schedule, null) != null ? [""] : []
          content {
            hours_in_cycle = each.value.snapshot_schedule_policy.hourly_schedule.hours_in_cycle
            start_time     = each.value.snapshot_schedule_policy.hourly_schedule.start_time
          }
        }

        dynamic "daily_schedule" {
          for_each = try(each.value.snapshot_schedule_policy.daily_schedule, null) != null ? [""] : []
          content {
            days_in_cycle = each.value.snapshot_schedule_policy.daily_schedule.days_in_cycle
            start_time    = each.value.snapshot_schedule_policy.daily_schedule.start_time
          }
        }

        dynamic "weekly_schedule" {
          for_each = each.value.snapshot_schedule_policy.weekly_schedule != null ? each.value.snapshot_schedule_policy.weekly_schedule : []
          content {
            dynamic "day_of_weeks" {
              for_each = weekly_schedule.value.day_of_weeks
              content {
                start_time = day_of_weeks.value.start_time
                day        = day_of_weeks.value.day
              }
            }
          }
        }
      }

      retention_policy {
        max_retention_days    = each.value.snapshot_schedule_policy.retention_policy.max_retention_days
        on_source_disk_delete = each.value.snapshot_schedule_policy.retention_policy.on_source_disk_delete
      }

      snapshot_properties {
        labels = merge(
          var.default_labels,
          each.value.snapshot_schedule_policy.snapshot_properties.labels,
          {
            "name"      = each.value.name
            "component" = "snapshot"
          }
        )
        storage_locations = each.value.snapshot_schedule_policy.snapshot_properties.storage_locations
        guest_flush       = each.value.snapshot_schedule_policy.snapshot_properties.guest_flush
      }
    }
  }

  # Group Placement Policy
  dynamic "group_placement_policy" {
    for_each = each.value.group_placement_policy != null ? [""] : []
    content {
      vm_count                  = each.value.group_placement_policy.vm_count
      availability_domain_count = each.value.group_placement_policy.availability_domain_count
      collocation               = each.value.group_placement_policy.collocation
    }
  }

  # Instance Schedule Policy
  dynamic "instance_schedule_policy" {
    for_each = each.value.instance_schedule_policy != null ? [""] : []
    content {
      dynamic "vm_start_schedule" {
        for_each = try(each.value.instance_schedule_policy.vm_start_schedule, null) != null ? [""] : []
        content {
          schedule = each.value.instance_schedule_policy.vm_start_schedule.schedule
        }
      }

      dynamic "vm_stop_schedule" {
        for_each = try(each.value.instance_schedule_policy.vm_stop_schedule, null) != null ? [""] : []
        content {
          schedule = each.value.instance_schedule_policy.vm_stop_schedule.schedule
        }
      }

      time_zone       = each.value.instance_schedule_policy.time_zone
      start_time      = each.value.instance_schedule_policy.start_time
      expiration_time = each.value.instance_schedule_policy.expiration_time
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "snapshot_schedule_attachment" {
  for_each = {
    for disk in var.disk_snapshots : "${disk.disk_name}-${disk.policy_name}" => disk
  }

  name    = google_compute_resource_policy.compute_resource_policies[each.value.policy_name].name
  disk    = each.value.disk_name
  project = var.project_id
  zone    = var.zone

  depends_on = [
    google_compute_resource_policy.compute_resource_policies,
    google_compute_disk.compute_disks
  ]
}
