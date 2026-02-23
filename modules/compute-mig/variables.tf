variable "auto_healing_policies" {
  description = "Auto-healing configuration."
  type = object({
    health_check      = optional(string)
    initial_delay_sec = number
  })
  default = null
}

variable "autoscaler_config" {
  description = "Autoscaling configuration."
  type = object({
    max_replicas    = number
    min_replicas    = number
    cooldown_period = optional(number)
    mode            = optional(string)

    scaling_control = optional(object({
      down = optional(object({
        time_window_sec      = optional(number)
        max_replicas_fixed   = optional(number)
        max_replicas_percent = optional(number)
      }))
      in = optional(object({
        time_window_sec      = optional(number)
        max_replicas_fixed   = optional(number)
        max_replicas_percent = optional(number)
      }))
    }))

    scaling_signals = optional(object({
      cpu_utilization = optional(object({
        target                = number
        optimize_availability = optional(bool)
      }))
      load_balancing_utilization = optional(object({
        target = number
      }))
      metrics = optional(list(object({
        name                       = string
        type                       = string
        target_value               = number
        single_instance_assignment = optional(number)
        time_series_filter         = optional(string)
      })))
      schedules = optional(list(object({
        duration_sec          = number
        name                  = string
        cron_schedule         = string
        description           = optional(string)
        disabled              = optional(bool)
        timezone              = optional(string)
        min_required_replicas = number
      })))
    }))
  })
  default = null
}

variable "compute_instance_groups" {
  description = "Configuration for unmanaged instance groups."
  type = map(object({
    name                = string
    description         = optional(string)
    zone                = string
    network_self_link   = string
    instance_self_links = list(string)
    named_port          = optional(map(number))
    project             = optional(string)
  }))
  default = {}
}

variable "default_version_name" {
  description = "Name of the default instance template version."
  type        = string
  default     = "default"
}

variable "description" {
  description = "An optional description for the managed instance group."
  type        = string
  default     = null
}

variable "distribution_policy" {
  description = "Regional MIG distribution policy config."
  type = object({
    target_shape = optional(string)
    zones        = optional(list(string))
  })
  default = null
}

variable "health_check_config" {
  description = "Optional health check config block."
  type = object({
    description         = optional(string)
    check_interval_sec  = optional(number)
    timeout_sec         = optional(number)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    enable_logging      = optional(bool)

    http  = optional(object({ host = optional(string), request_path = optional(string), response = optional(string), port = optional(number), port_name = optional(string), proxy_header = optional(string), port_specification = optional(string) }))
    https = optional(object({ host = optional(string), request_path = optional(string), response = optional(string), port = optional(number), port_name = optional(string), proxy_header = optional(string), port_specification = optional(string) }))
    tcp   = optional(object({ port = optional(number), port_name = optional(string), proxy_header = optional(string), port_specification = optional(string), request = optional(string), response = optional(string) }))
    ssl   = optional(object({ port = optional(number), port_name = optional(string), proxy_header = optional(string), port_specification = optional(string), request = optional(string), response = optional(string) }))
    http2 = optional(object({ host = optional(string), request_path = optional(string), response = optional(string), port = optional(number), port_name = optional(string), proxy_header = optional(string), port_specification = optional(string) }))
    grpc  = optional(object({ port = optional(number), port_name = optional(string), port_specification = optional(string), service_name = optional(string) }))
  })
  default = null
}

variable "instance_template" {
  description = "The self_link of the instance template to use."
  type        = string
}

variable "join_separator" {
  description = "String to join prefix and name."
  type        = string
  default     = "-"
}

variable "location" {
  description = "The location (region or zone) where resources will be created. Use a zone name for zonal resources and a region name for regional."
  type        = string
}

variable "name" {
  description = "The base name for all resources created by this module."
  type        = string
}

variable "named_ports" {
  description = "Map of named ports (e.g. http = 80)."
  type        = map(number)
  default     = null
}

variable "project_id" {
  description = "The ID of the GCP project where resources will be created."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to prepend to resource names."
  type        = string
  default     = null
}

variable "stateful_config" {
  description = "Stateful per-instance configuration map."
  type = map(object({
    minimal_action          = string
    most_disruptive_action  = string
    remove_state_on_destroy = bool
    preserved_state = optional(object({
      metadata = optional(map(string))
      disks = optional(map(object({
        source                      = string
        delete_on_instance_deletion = optional(bool)
        read_only                   = optional(bool)
      })))
    }))
  }))
  default = {}
}

variable "stateful_disks" {
  description = "Map of stateful disk device names and persistence flags."
  type        = map(bool)
  default     = {}
}

variable "target_pools" {
  description = "List of target pools to attach."
  type        = list(string)
  default     = []
}

variable "target_size" {
  description = "Target size of the instance group."
  type        = number
  default     = null
}

variable "update_policy" {
  description = "Update policy for rolling updates."
  type = object({
    minimal_action = string
    type           = string
    max_surge = optional(object({
      fixed   = optional(number)
      percent = optional(number)
    }))
    max_unavailable = optional(object({
      fixed   = optional(number)
      percent = optional(number)
    }))
    min_ready_sec                = optional(number)
    replacement_method           = optional(string)
    most_disruptive_action       = optional(string)
    regional_redistribution_type = optional(string)
  })
  default = null
}

variable "versions" {
  description = "Additional instance template versions with optional size overrides."
  type = map(object({
    instance_template = string
    target_size = optional(object({
      fixed   = optional(number)
      percent = optional(number)
    }))
  }))
  default = {}
}

variable "wait_for_instances" {
  description = "Whether to wait for instances and expected status."
  type = object({
    enabled = bool
    status  = optional(string)
  })
  default = {
    enabled = false
  }
}