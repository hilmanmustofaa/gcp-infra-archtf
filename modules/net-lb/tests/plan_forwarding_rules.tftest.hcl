run "plan_forwarding_rules" {
  command = plan

  variables {
    resource_prefix = "test"

    default_labels = {
      environment = "dev"
      team        = "network"
    }

    compute_forwarding_rules = {
      fr-regional = {
        name                   = "fr-regional"
        region                 = "us-central1"
        project                = "test-project"
        load_balancing_scheme  = "EXTERNAL"
        backend_service        = null
        ip_protocol            = "TCP"
        ports                  = ["80"]
        description            = null
        ip_address             = null
        port_range             = null
        network                = null
        subnetwork             = null
        allow_global_access    = null
        all_ports              = null
        network_tier           = null
        service_label          = null
        is_mirroring_collector = null
        labels = {
          app = "web"
        }
      }
    }

    compute_global_forwarding_rules = {
      fr-global = {
        name                  = "fr-global"
        project               = "test-project"
        target                = "target-proxy"
        port_range            = "443"
        description           = null
        ip_address            = null
        ip_protocol           = null
        load_balancing_scheme = null
        network               = null
        labels = {
          service = "api"
        }
      }
    }

    compute_target_https_proxies = {
      target-proxy = {
        name    = "target-proxy"
        project = "test-project"
        url_map = "url-map"
      }
    }

    compute_url_maps = {
      url-map = {
        name            = "url-map"
        project         = "test-project"
        default_service = "backend-service"
        description     = null
        host_rule       = []
        path_matcher    = []
      }
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
      backend-service = {
        name                            = "backend-service"
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
        health_checks                   = ["hc-1"]
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
  }

  # Verify Regional Forwarding Rule Labels
  assert {
    condition     = google_compute_forwarding_rule.compute_forwarding_rules["fr-regional"].labels["environment"] == "dev"
    error_message = "Regional FR should have default label environment=dev"
  }

  assert {
    condition     = google_compute_forwarding_rule.compute_forwarding_rules["fr-regional"].labels["app"] == "web"
    error_message = "Regional FR should have specific label app=web"
  }

  # Verify Global Forwarding Rule Labels
  assert {
    condition     = google_compute_global_forwarding_rule.compute_global_forwarding_rules["fr-global"].labels["team"] == "network"
    error_message = "Global FR should have default label team=network"
  }

  assert {
    condition     = google_compute_global_forwarding_rule.compute_global_forwarding_rules["fr-global"].labels["service"] == "api"
    error_message = "Global FR should have specific label service=api"
  }
}
