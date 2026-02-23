resource "google_compute_region_backend_service" "compute_region_backend_services" {
  provider = google-beta
  for_each = var.compute_region_backend_services

  name                    = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  affinity_cookie_ttl_sec = each.value.affinity_cookie_ttl_sec
  dynamic "backend" {
    for_each = each.value.backend

    content {
      balancing_mode               = backend.value.balancing_mode
      capacity_scaler              = backend.value.capacity_scaler
      description                  = backend.value.description
      failover                     = backend.value.failover
      group                        = backend.value.group
      max_connections              = backend.value.max_connections
      max_connections_per_instance = backend.value.max_connections_per_instance
      max_connections_per_endpoint = backend.value.max_connections_per_endpoint
      max_rate                     = backend.value.max_rate
      max_rate_per_instance        = backend.value.max_rate_per_instance
      max_rate_per_endpoint        = backend.value.max_rate_per_endpoint
      max_utilization              = backend.value.max_utilization
    }
  }
  dynamic "circuit_breakers" {
    for_each = length(each.value.circuit_breakers) > 0 && each.value.load_balancing_scheme == "INTERNAL_MANAGED" && (each.value.protocol == "HTTP" || each.value.protocol == "HTTPS" || each.value.protocol == "HTTP2") ? { "circuit_breakers" = each.value.circuit_breakers } : {}

    content {
      connect_timeout {
        seconds = circuit_breakers.value.connect_timeout.seconds
        nanos   = circuit_breakers.value.connect_timeout.nanos
      }
      max_requests_per_connection = circuit_breakers.value.max_requests_per_connection
      max_connections             = circuit_breakers.value.max_connections
      max_pending_requests        = circuit_breakers.value.max_pending_requests
      max_requests                = circuit_breakers.value.max_requests
      max_retries                 = circuit_breakers.value.max_retries
    }
  }
  dynamic "consistent_hash" {
    for_each = length(each.value.consistent_hash) > 0 && each.value.load_balancing_scheme == "INTERNAL_MANAGED" && (each.value.protocol == "HTTP" || each.value.protocol == "HTTPS" || each.value.protocol == "HTTP2") ? { "consistent_hash" = each.value.consistent_hash } : {}

    content {
      http_cookie {
        ttl {
          seconds = consistent_hash.value.http_cookie.ttl.seconds
          nanos   = consistent_hash.value.http_cookie.ttl.nanos
        }
        name = consistent_hash.value.http_cookie.name
        path = consistent_hash.value.http_cookie.path
      }
      http_header_name  = consistent_hash.value.http_header_name
      minimum_ring_size = consistent_hash.value.minimum_ring_size
    }
  }
  connection_draining_timeout_sec = each.value.connection_draining_timeout_sec
  description                     = each.value.description
  dynamic "failover_policy" {
    for_each = length(each.value.failover_policy) > 0 && each.value.load_balancing_scheme == "INTERNAL" && (each.value.protocol == "TCP" || each.value.protocol == "UDP") ? { "failover_policy" = each.value.failover_policy } : {}

    content {
      failover_ratio                       = failover_policy.value.failover_ratio
      drop_traffic_if_unhealthy            = failover_policy.value.drop_traffic_if_unhealthy
      disable_connection_drain_on_failover = failover_policy.value.disable_connection_drain_on_failover
    }
  }
  health_checks         = [for key, value in google_compute_region_health_check.compute_region_health_checks : value.id if contains(each.value.health_checks, key)]
  load_balancing_scheme = each.value.load_balancing_scheme
  locality_lb_policy    = each.value.locality_lb_policy
  dynamic "outlier_detection" {
    for_each = length(each.value.outlier_detection) > 0 && each.value.load_balancing_scheme == "INTERNAL_MANAGED" && (each.value.protocol == "HTTP" || each.value.protocol == "HTTPS" || each.value.protocol == "HTTP2") ? { "outlier_detection" = each.value.outlier_detection } : {}

    content {
      base_ejection_time {
        seconds = outlier_detection.value.base_ejection_time.seconds
        nanos   = outlier_detection.value.base_ejection_time.nanos
      }
      consecutive_errors                    = outlier_detection.value.consecutive_errors
      consecutive_gateway_failure           = outlier_detection.value.consecutive_gateway_failure
      enforcing_consecutive_errors          = outlier_detection.value.enforcing_consecutive_errors
      enforcing_consecutive_gateway_failure = outlier_detection.value.enforcing_consecutive_gateway_failure
      enforcing_success_rate                = outlier_detection.value.enforcing_success_rate
      interval {
        seconds = outlier_detection.value.interval.seconds
        nanos   = outlier_detection.value.interval.nanos
      }
      max_ejection_percent        = outlier_detection.value.max_ejection_percent
      success_rate_minimum_hosts  = outlier_detection.value.success_rate_minimum_hosts
      success_rate_request_volume = outlier_detection.value.success_rate_request_volume
      success_rate_stdev_factor   = outlier_detection.value.success_rate_stdev_factor
    }
  }
  port_name        = each.value.port_name
  protocol         = each.value.protocol
  session_affinity = each.value.session_affinity
  timeout_sec      = each.value.timeout_sec
  dynamic "log_config" {
    for_each = each.value.load_balancing_scheme == "INTERNAL_MANAGED" && (each.value.protocol == "HTTP" || each.value.protocol == "HTTPS" || each.value.protocol == "HTTP2") && each.value.log_config.enable ? { "log_config" = each.value.log_config } : {}

    content {
      enable      = log_config.value.enable
      sample_rate = log_config.value.sample_rate
    }
  }
  network = each.value.network
  region  = each.value.region
  project = each.value.project

  lifecycle {
    ignore_changes = [
      failover_policy
    ]
  }
}
