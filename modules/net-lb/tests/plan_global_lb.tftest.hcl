run "plan_global_lb" {
  command = plan

  variables {
    resource_prefix = "test"

    default_labels = {
      env = "prod"
    }

    compute_health_checks = {
      hc-1 = {
        name                = "hc-1"
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        health_check = {
          protocol = "HTTP"
          port     = 80
        }
        log_config = null
        project    = "test-project"
      }
    }

    compute_backend_services = {
      bs-1 = {
        name                            = "bs-1"
        health_checks                   = ["hc-1"]
        project                         = "test-project"
        affinity_cookie_ttl_sec         = null
        backend                         = []
        circuit_breakers                = {}
        consistent_hash                 = {}
        connection_draining_timeout_sec = null
        custom_request_headers          = null
        custom_response_headers         = null
        description                     = null
        enable_cdn                      = null
        load_balancing_scheme           = null
        locality_lb_policy              = null
        outlier_detection               = {}
        port_name                       = null
        protocol                        = null
        security_policy                 = null
        security_settings = {
          client_tls_policy = null
        }
        session_affinity = null
        timeout_sec      = 30
        log_config = {
          enable = false
        }
      }
    }

    compute_url_maps = {
      um-1 = {
        name            = "um-1"
        default_service = "bs-1"
        project         = "test-project"
        description     = null
        host_rule       = []
        path_matcher    = []
      }
    }

    compute_target_https_proxies = {
      tp-1 = {
        name    = "tp-1"
        url_map = "um-1"
        project = "test-project"
      }
    }

    compute_global_forwarding_rules = {
      gfr-1 = {
        name                  = "gfr-1"
        target                = "tp-1"
        port_range            = "443"
        project               = "test-project"
        description           = null
        ip_address            = null
        ip_protocol           = null
        load_balancing_scheme = null
        network               = null
        labels = {
          app = "global-app"
        }
      }
    }
  }

  # Verify Health Check
  assert {
    condition     = google_compute_health_check.compute_health_checks["hc-1"].name == "test-hc-1"
    error_message = "Health Check name incorrect"
  }

  # Verify Backend Service
  assert {
    condition     = google_compute_backend_service.compute_backend_services["bs-1"].name == "test-bs-1"
    error_message = "Backend Service name incorrect"
  }

  # Verify URL Map
  assert {
    condition     = google_compute_url_map.compute_url_maps["um-1"].name == "test-um-1"
    error_message = "URL Map name incorrect"
  }

  # Verify Target Proxy
  assert {
    condition     = google_compute_target_https_proxy.compute_target_https_proxies["tp-1"].name == "test-tp-1"
    error_message = "Target Proxy name incorrect"
  }

  # Verify Global Forwarding Rule
  assert {
    condition     = google_compute_global_forwarding_rule.compute_global_forwarding_rules["gfr-1"].name == "test-gfr-1"
    error_message = "Global Forwarding Rule name incorrect"
  }

  assert {
    condition     = google_compute_global_forwarding_rule.compute_global_forwarding_rules["gfr-1"].labels["env"] == "prod"
    error_message = "Global Forwarding Rule default label missing"
  }
}
