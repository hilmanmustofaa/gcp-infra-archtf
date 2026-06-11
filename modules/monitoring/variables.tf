variable "project_id" {
  description = "The project ID to deploy monitoring resources into."
  type        = string
}

variable "default_labels" {
  description = "Default labels applied to alert policies and notification channels (as user_labels). Must include 'env', 'project', and 'owner' for FinOps governance."
  type        = map(string)

  validation {
    condition = alltrue([
      contains(keys(var.default_labels), "env"),
      contains(keys(var.default_labels), "project"),
      contains(keys(var.default_labels), "owner"),
    ])
    error_message = "Labels must include 'env', 'project', and 'owner' keys for FinOps compliance."
  }
}

variable "notification_channels" {
  description = "Map of notification channels, keyed by a logical name (referenced from alert_policies.notification_channels)."
  type = map(object({
    display_name = string
    type         = string                    # e.g. "email", "pubsub", "slack", "sms"
    labels       = optional(map(string), {}) # channel config, e.g. { email_address = "..." }
    description  = optional(string)
    enabled      = optional(bool, true)
    user_labels  = optional(map(string), {})
  }))
  default  = {}
  nullable = false
}

variable "alert_policies" {
  description = "Map of alert policies, keyed by a logical name."
  type = map(object({
    display_name = string
    combiner     = optional(string, "OR")
    enabled      = optional(bool, true)

    # Channel references: either a key in var.notification_channels or a full
    # channel resource id. Keys are resolved to created channel ids.
    notification_channels = optional(list(string), [])

    documentation = optional(object({
      content   = string
      mime_type = optional(string, "text/markdown")
      subject   = optional(string)
    }))

    user_labels = optional(map(string), {})

    conditions = list(object({
      display_name = string
      condition_threshold = optional(object({
        filter               = string
        comparison           = string
        threshold_value      = optional(number)
        duration             = string
        alignment_period     = optional(string)
        per_series_aligner   = optional(string)
        cross_series_reducer = optional(string)
        group_by_fields      = optional(list(string))
        trigger_count        = optional(number)
      }))
      condition_absent = optional(object({
        filter   = string
        duration = string
      }))
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for k, v in var.alert_policies :
      contains(["AND", "OR", "AND_WITH_MATCHING_RESOURCE"], v.combiner)
    ])
    error_message = "alert_policies combiner must be one of AND, OR, AND_WITH_MATCHING_RESOURCE."
  }

  validation {
    condition = alltrue([
      for k, v in var.alert_policies : alltrue([
        for c in v.conditions :
        (c.condition_threshold != null) != (c.condition_absent != null)
      ])
    ])
    error_message = "Each alert condition must set exactly one of condition_threshold or condition_absent."
  }
}

variable "uptime_checks" {
  description = "Map of uptime check configurations, keyed by a logical name. Uptime checks do not support user_labels."
  type = map(object({
    display_name = string
    timeout      = optional(string, "10s")
    period       = optional(string, "60s")

    monitored_resource = object({
      type   = string      # e.g. "uptime_url"
      labels = map(string) # e.g. { host = "example.com", project_id = "..." }
    })

    http_check = optional(object({
      path           = optional(string, "/")
      port           = optional(number)
      use_ssl        = optional(bool, true)
      validate_ssl   = optional(bool, true)
      request_method = optional(string)
    }))

    tcp_check = optional(object({
      port = number
    }))

    selected_regions = optional(list(string))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for k, v in var.uptime_checks :
      (v.http_check != null) != (v.tcp_check != null)
    ])
    error_message = "Each uptime check must set exactly one of http_check or tcp_check."
  }
}
