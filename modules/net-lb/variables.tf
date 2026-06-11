variable "compute_health_checks" {
  description = "A map of (global) health check objects."
  type = map(object({
    name                = string
    project             = optional(string)
    check_interval_sec  = optional(number)
    description         = optional(string)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    timeout_sec         = optional(number)
    health_check = object({
      protocol           = string
      host               = optional(string)
      request_path       = optional(string)
      response           = optional(string)
      request            = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string)
      port_specification = optional(string)
      grpc_service_name  = optional(string)
    })
    log_config = optional(object({
      enable = optional(bool, false)
    }))
  }))
  default = {}
}

variable "compute_region_health_checks" {
  description = "A map of regional health check objects."
  type = map(object({
    name                = string
    project             = optional(string)
    region              = optional(string)
    check_interval_sec  = optional(number)
    description         = optional(string)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    timeout_sec         = optional(number)
    health_check = object({
      protocol           = string
      host               = optional(string)
      request_path       = optional(string)
      response           = optional(string)
      request            = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string)
      port_specification = optional(string)
      grpc_service_name  = optional(string)
    })
    log_config = optional(object({
      enable = optional(bool, false)
    }))
  }))
  default = {}
}

variable "compute_backend_services" {
  description = "A map of (global) backend service objects."
  type = map(object({
    name                            = string
    project                         = optional(string)
    health_checks                   = list(string)
    affinity_cookie_ttl_sec         = optional(number)
    connection_draining_timeout_sec = optional(number)
    custom_request_headers          = optional(list(string))
    custom_response_headers         = optional(list(string))
    description                     = optional(string)
    enable_cdn                      = optional(bool)
    load_balancing_scheme           = optional(string)
    locality_lb_policy              = optional(string)
    port_name                       = optional(string)
    protocol                        = optional(string)
    security_policy                 = optional(string)
    session_affinity                = optional(string)
    timeout_sec                     = optional(number)
    backend = optional(list(object({
      balancing_mode               = optional(string)
      capacity_scaler              = optional(number)
      description                  = optional(string)
      group                        = optional(string)
      max_connections              = optional(number)
      max_connections_per_instance = optional(number)
      max_connections_per_endpoint = optional(number)
      max_rate                     = optional(number)
      max_rate_per_instance        = optional(number)
      max_rate_per_endpoint        = optional(number)
      max_utilization              = optional(number)
    })), [])
    circuit_breakers = optional(object({
      connect_timeout             = optional(object({ seconds = optional(number), nanos = optional(number) }))
      max_requests_per_connection = optional(number)
      max_connections             = optional(number)
      max_pending_requests        = optional(number)
      max_requests                = optional(number)
      max_retries                 = optional(number)
    }))
    consistent_hash = optional(object({
      http_cookie = optional(object({
        ttl  = optional(object({ seconds = optional(number), nanos = optional(number) }))
        name = optional(string)
        path = optional(string)
      }))
      http_header_name  = optional(string)
      minimum_ring_size = optional(number)
    }))
    outlier_detection = optional(object({
      base_ejection_time                    = optional(object({ seconds = optional(number), nanos = optional(number) }))
      consecutive_errors                    = optional(number)
      consecutive_gateway_failure           = optional(number)
      enforcing_consecutive_errors          = optional(number)
      enforcing_consecutive_gateway_failure = optional(number)
      enforcing_success_rate                = optional(number)
      interval                              = optional(object({ seconds = optional(number), nanos = optional(number) }))
      max_ejection_percent                  = optional(number)
      success_rate_minimum_hosts            = optional(number)
      success_rate_request_volume           = optional(number)
      success_rate_stdev_factor             = optional(number)
    }))
    security_settings = optional(object({
      client_tls_policy = optional(string)
      subject_alt_names = optional(list(string))
    }))
    log_config = optional(object({
      enable      = optional(bool, false)
      sample_rate = optional(number)
    }))
  }))
  default = {}
}

variable "compute_region_backend_services" {
  description = "A map of regional backend service objects."
  type = map(object({
    name                            = string
    project                         = optional(string)
    region                          = optional(string)
    network                         = optional(string)
    health_checks                   = list(string)
    affinity_cookie_ttl_sec         = optional(number)
    connection_draining_timeout_sec = optional(number)
    description                     = optional(string)
    load_balancing_scheme           = optional(string)
    locality_lb_policy              = optional(string)
    port_name                       = optional(string)
    protocol                        = optional(string)
    session_affinity                = optional(string)
    timeout_sec                     = optional(number)
    backend = optional(list(object({
      balancing_mode               = optional(string)
      capacity_scaler              = optional(number)
      description                  = optional(string)
      failover                     = optional(bool)
      group                        = optional(string)
      max_connections              = optional(number)
      max_connections_per_instance = optional(number)
      max_connections_per_endpoint = optional(number)
      max_rate                     = optional(number)
      max_rate_per_instance        = optional(number)
      max_rate_per_endpoint        = optional(number)
      max_utilization              = optional(number)
    })), [])
    circuit_breakers = optional(object({
      connect_timeout             = optional(object({ seconds = optional(number), nanos = optional(number) }))
      max_requests_per_connection = optional(number)
      max_connections             = optional(number)
      max_pending_requests        = optional(number)
      max_requests                = optional(number)
      max_retries                 = optional(number)
    }))
    consistent_hash = optional(object({
      http_cookie = optional(object({
        ttl  = optional(object({ seconds = optional(number), nanos = optional(number) }))
        name = optional(string)
        path = optional(string)
      }))
      http_header_name  = optional(string)
      minimum_ring_size = optional(number)
    }))
    outlier_detection = optional(object({
      base_ejection_time                    = optional(object({ seconds = optional(number), nanos = optional(number) }))
      consecutive_errors                    = optional(number)
      consecutive_gateway_failure           = optional(number)
      enforcing_consecutive_errors          = optional(number)
      enforcing_consecutive_gateway_failure = optional(number)
      enforcing_success_rate                = optional(number)
      interval                              = optional(object({ seconds = optional(number), nanos = optional(number) }))
      max_ejection_percent                  = optional(number)
      success_rate_minimum_hosts            = optional(number)
      success_rate_request_volume           = optional(number)
      success_rate_stdev_factor             = optional(number)
    }))
    failover_policy = optional(object({
      failover_ratio                       = optional(number)
      drop_traffic_if_unhealthy            = optional(bool)
      disable_connection_drain_on_failover = optional(bool)
    }))
    log_config = optional(object({
      enable      = optional(bool, false)
      sample_rate = optional(number)
    }))
  }))
  default = {}
}

variable "compute_url_maps" {
  description = "A map of URL map objects."
  type = map(object({
    name            = string
    default_service = string
    project         = optional(string)
    description     = optional(string)
    host_rule = optional(list(object({
      description  = optional(string)
      hosts        = list(string)
      path_matcher = string
    })), [])
    path_matcher = optional(list(object({
      default_service = string
      description     = optional(string)
      name            = string
    })), [])
  }))
  default = {}
}

variable "compute_target_https_proxies" {
  description = "A map of target HTTPS proxy objects."
  type = map(object({
    name             = string
    url_map          = string
    project          = optional(string)
    description      = optional(string)
    ssl_certificates = optional(list(string))
  }))
  default = {}
}

variable "compute_forwarding_rules" {
  description = "A map of (regional) forwarding rule objects."
  type = map(object({
    name                   = string
    project                = optional(string)
    region                 = optional(string)
    is_mirroring_collector = optional(bool)
    description            = optional(string)
    ip_address             = optional(string)
    ip_protocol            = optional(string)
    backend_service        = optional(string)
    load_balancing_scheme  = optional(string)
    network                = optional(string)
    port_range             = optional(string)
    ports                  = optional(list(string))
    subnetwork             = optional(string)
    allow_global_access    = optional(bool)
    all_ports              = optional(bool)
    network_tier           = optional(string)
    service_label          = optional(string)
    labels                 = optional(map(string), {})
  }))
  default = {}
}

variable "compute_global_forwarding_rules" {
  description = "A map of global forwarding rule objects."
  type = map(object({
    name                  = string
    target                = string
    project               = optional(string)
    description           = optional(string)
    ip_address            = optional(string)
    ip_protocol           = optional(string)
    load_balancing_scheme = optional(string)
    network               = optional(string)
    port_range            = optional(string)
    labels                = optional(map(string), {})
  }))
  default = {}
}

variable "default_labels" {
  description = "Default labels to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "join_separator" {
  description = "The separator to use when joining the prefix and the name."
  type        = string
  default     = "-"
}

variable "resource_prefix" {
  description = "A prefix for the resource names."
  type        = string
  default     = null
}
