locals {
  # ===== FinOps labels. =====
  # Refer to Cloud Asset Inventory asset types:
  # https://cloud.google.com/asset-inventory/docs/asset-types
  finops_labels_default = {
    gcp_asset_type = "monitoring-googleapis-com--alertpolicy"
    gcp_service    = "monitoring-googleapis-com"
    tf_module      = "monitoring"
    tf_layer       = "observability"
    tf_resource    = "alert_policy"
  }

  finops_labels = merge(
    local.finops_labels_default,
    var.default_labels,
  )
}

resource "google_monitoring_notification_channel" "channels" {
  for_each = var.notification_channels

  project      = var.project_id
  display_name = each.value.display_name
  type         = each.value.type
  labels       = each.value.labels
  description  = each.value.description
  enabled      = each.value.enabled

  user_labels = merge(
    local.finops_labels,
    each.value.user_labels,
    { tf_resource = "notification_channel" },
  )
}

resource "google_monitoring_alert_policy" "policies" {
  for_each = var.alert_policies

  project      = var.project_id
  display_name = each.value.display_name
  combiner     = each.value.combiner
  enabled      = each.value.enabled

  # Resolve channel keys (defined in this module) to their resource ids;
  # pass through anything that is already a full channel id.
  notification_channels = [
    for ch in each.value.notification_channels :
    contains(keys(var.notification_channels), ch) ? google_monitoring_notification_channel.channels[ch].id : ch
  ]

  user_labels = merge(
    local.finops_labels,
    each.value.user_labels,
  )

  dynamic "documentation" {
    for_each = each.value.documentation != null ? [each.value.documentation] : []
    content {
      content   = documentation.value.content
      mime_type = documentation.value.mime_type
      subject   = documentation.value.subject
    }
  }

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_threshold" {
        for_each = conditions.value.condition_threshold != null ? [conditions.value.condition_threshold] : []
        content {
          filter          = condition_threshold.value.filter
          comparison      = condition_threshold.value.comparison
          threshold_value = condition_threshold.value.threshold_value
          duration        = condition_threshold.value.duration

          dynamic "aggregations" {
            for_each = condition_threshold.value.alignment_period != null ? [""] : []
            content {
              alignment_period     = condition_threshold.value.alignment_period
              per_series_aligner   = condition_threshold.value.per_series_aligner
              cross_series_reducer = condition_threshold.value.cross_series_reducer
              group_by_fields      = condition_threshold.value.group_by_fields
            }
          }

          dynamic "trigger" {
            for_each = condition_threshold.value.trigger_count != null ? [""] : []
            content {
              count = condition_threshold.value.trigger_count
            }
          }
        }
      }

      dynamic "condition_absent" {
        for_each = conditions.value.condition_absent != null ? [conditions.value.condition_absent] : []
        content {
          filter   = condition_absent.value.filter
          duration = condition_absent.value.duration
        }
      }
    }
  }
}

resource "google_monitoring_uptime_check_config" "uptime" {
  for_each = var.uptime_checks

  project      = var.project_id
  display_name = each.value.display_name
  timeout      = each.value.timeout
  period       = each.value.period

  monitored_resource {
    type   = each.value.monitored_resource.type
    labels = each.value.monitored_resource.labels
  }

  dynamic "http_check" {
    for_each = each.value.http_check != null ? [each.value.http_check] : []
    content {
      path           = http_check.value.path
      port           = http_check.value.port
      use_ssl        = http_check.value.use_ssl
      validate_ssl   = http_check.value.validate_ssl
      request_method = http_check.value.request_method
    }
  }

  dynamic "tcp_check" {
    for_each = each.value.tcp_check != null ? [each.value.tcp_check] : []
    content {
      port = tcp_check.value.port
    }
  }

  selected_regions = each.value.selected_regions
}
