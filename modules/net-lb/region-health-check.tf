resource "google_compute_region_health_check" "compute_region_health_checks" {
  provider = google-beta
  for_each = var.compute_region_health_checks

  name                = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  check_interval_sec  = try(each.value.check_interval_sec, null)
  description         = try(each.value.description, null)
  healthy_threshold   = try(each.value.healthy_threshold, null)
  unhealthy_threshold = try(each.value.unhealthy_threshold, null)
  timeout_sec         = try(each.value.timeout_sec, null)
  dynamic "http_health_check" {
    for_each = each.value.health_check.protocol == "HTTP" ? { "http_health_check" = each.value.health_check } : {}

    content {
      host               = try(http_health_check.value.host, null)
      request_path       = try(http_health_check.value.request_path, null)
      response           = try(http_health_check.value.response, null)
      port               = try(http_health_check.value.port, null)
      port_name          = try(http_health_check.value.port_name, null)
      proxy_header       = try(http_health_check.value.proxy_header, null)
      port_specification = try(http_health_check.value.port_specification, null)
    }
  }
  dynamic "https_health_check" {
    for_each = each.value.health_check.protocol == "HTTPS" ? { "https_health_check" = each.value.health_check } : {}

    content {
      host               = try(https_health_check.value.host, null)
      request_path       = try(https_health_check.value.request_path, null)
      response           = try(https_health_check.value.response, null)
      port               = try(https_health_check.value.port, null)
      port_name          = try(https_health_check.value.port_name, null)
      proxy_header       = try(https_health_check.value.proxy_header, null)
      port_specification = try(https_health_check.value.port_specification, null)
    }
  }
  dynamic "tcp_health_check" {
    for_each = each.value.health_check.protocol == "TCP" ? { "tcp_health_check" = each.value.health_check } : {}

    content {
      request            = try(tcp_health_check.value.request, null)
      response           = try(tcp_health_check.value.response, null)
      port               = try(tcp_health_check.value.port, null)
      port_name          = try(tcp_health_check.value.port_name, null)
      proxy_header       = try(tcp_health_check.value.proxy_header, null)
      port_specification = try(tcp_health_check.value.port_specification, null)
    }
  }
  dynamic "ssl_health_check" {
    for_each = each.value.health_check.protocol == "SSL" ? { "ssl_health_check" = each.value.health_check } : {}

    content {
      request            = try(ssl_health_check.value.request, null)
      response           = try(ssl_health_check.value.response, null)
      port               = try(ssl_health_check.value.port, null)
      port_name          = try(ssl_health_check.value.port_name, null)
      proxy_header       = try(ssl_health_check.value.proxy_header, null)
      port_specification = try(ssl_health_check.value.port_specification, null)
    }
  }
  dynamic "http2_health_check" {
    for_each = each.value.health_check.protocol == "HTTP2" ? { "http2_health_check" = each.value.health_check } : {}

    content {
      host               = try(http2_health_check.value.host, null)
      request_path       = try(http2_health_check.value.request_path, null)
      response           = try(http2_health_check.value.response, null)
      port               = try(http2_health_check.value.port, null)
      port_name          = try(http2_health_check.value.port_name, null)
      proxy_header       = try(http2_health_check.value.proxy_header, null)
      port_specification = try(http2_health_check.value.port_specification, null)
    }
  }
  dynamic "grpc_health_check" {
    for_each = each.value.health_check.protocol == "gRPC" ? { "grpc_health_check" = each.value.health_check } : {}

    content {
      port               = try(grpc_health_check.value.port, null)
      port_name          = try(grpc_health_check.value.port_name, null)
      port_specification = try(grpc_health_check.value.port_specification, null)
      grpc_service_name  = try(grpc_health_check.value.grpc_service_name, null)
    }
  }
  dynamic "log_config" {
    for_each = each.value.log_config != null ? { "log_config" = each.value.log_config } : {}

    content {
      enable = log_config.value.enable
    }
  }
  region  = each.value.region
  project = each.value.project
}
