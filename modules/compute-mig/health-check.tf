locals {
  hc       = var.health_check_config
  hc_grpc  = try(local.hc.grpc, null) != null
  hc_http  = try(local.hc.http, null) != null
  hc_http2 = try(local.hc.http2, null) != null
  hc_https = try(local.hc.https, null) != null
  hc_ssl   = try(local.hc.ssl, null) != null
  hc_tcp   = try(local.hc.tcp, null) != null
}

resource "google_compute_health_check" "health_checks" {
  provider = google-beta
  count    = local.hc != null ? 1 : 0

  project             = var.project_id
  name                = var.name
  description         = try(local.hc.description, null)
  check_interval_sec  = try(local.hc.check_interval_sec, null)
  timeout_sec         = try(local.hc.timeout_sec, null)
  healthy_threshold   = try(local.hc.healthy_threshold, null)
  unhealthy_threshold = try(local.hc.unhealthy_threshold, null)

  dynamic "http_health_check" {
    for_each = local.hc_http ? [""] : []
    content {
      host               = try(local.hc.http.host, null)
      request_path       = try(local.hc.http.request_path, null)
      response           = try(local.hc.http.response, null)
      port               = try(local.hc.http.port, null)
      port_name          = try(local.hc.http.port_name, null)
      proxy_header       = try(local.hc.http.proxy_header, null)
      port_specification = try(local.hc.http.port_specification, null)
    }
  }

  dynamic "https_health_check" {
    for_each = local.hc_https ? [""] : []
    content {
      host               = try(local.hc.https.host, null)
      request_path       = try(local.hc.https.request_path, null)
      response           = try(local.hc.https.response, null)
      port               = try(local.hc.https.port, null)
      port_name          = try(local.hc.https.port_name, null)
      proxy_header       = try(local.hc.https.proxy_header, null)
      port_specification = try(local.hc.https.port_specification, null)
    }
  }

  dynamic "tcp_health_check" {
    for_each = local.hc_tcp ? [""] : []
    content {
      port               = try(local.hc.tcp.port, null)
      port_name          = try(local.hc.tcp.port_name, null)
      proxy_header       = try(local.hc.tcp.proxy_header, null)
      port_specification = try(local.hc.tcp.port_specification, null)
      request            = try(local.hc.tcp.request, null)
      response           = try(local.hc.tcp.response, null)
    }
  }

  dynamic "ssl_health_check" {
    for_each = local.hc_ssl ? [""] : []
    content {
      port               = try(local.hc.ssl.port, null)
      port_name          = try(local.hc.ssl.port_name, null)
      proxy_header       = try(local.hc.ssl.proxy_header, null)
      port_specification = try(local.hc.ssl.port_specification, null)
      request            = try(local.hc.ssl.request, null)
      response           = try(local.hc.ssl.response, null)
    }
  }

  dynamic "http2_health_check" {
    for_each = local.hc_http2 ? [""] : []
    content {
      host               = try(local.hc.http2.host, null)
      request_path       = try(local.hc.http2.request_path, null)
      response           = try(local.hc.http2.response, null)
      port               = try(local.hc.http2.port, null)
      port_name          = try(local.hc.http2.port_name, null)
      proxy_header       = try(local.hc.http2.proxy_header, null)
      port_specification = try(local.hc.http2.port_specification, null)
    }
  }

  dynamic "grpc_health_check" {
    for_each = local.hc_grpc ? [""] : []
    content {
      port               = try(local.hc.grpc.port, null)
      port_name          = try(local.hc.grpc.port_name, null)
      port_specification = try(local.hc.grpc.port_specification, null)
      grpc_service_name  = try(local.hc.grpc.service_name, null)
    }
  }

  dynamic "log_config" {
    for_each = try(local.hc.enable_logging, false) ? [""] : []
    content {
      enable = true
    }
  }
}
