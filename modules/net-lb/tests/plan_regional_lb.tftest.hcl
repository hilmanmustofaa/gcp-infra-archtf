run "plan_regional_lb" {
  command = plan

  variables {
    resource_prefix = "test"

    default_labels = {
      env = "test"
    }

    compute_region_health_checks = {
      rhc-1 = {
        name                = "rhc-1"
        region              = "us-central1"
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        health_check = {
          protocol = "TCP"
          port     = 80
        }
        log_config = null
        project    = "test-project"
      }
    }

    compute_region_backend_services = {
      rbs-1 = {
        name                            = "rbs-1"
        region                          = "us-central1"
        load_balancing_scheme           = "INTERNAL"
        protocol                        = "TCP"
        health_checks                   = ["rhc-1"]
        network                         = "default"
        project                         = "test-project"
        affinity_cookie_ttl_sec         = null
        backend                         = []
        circuit_breakers                = {}
        consistent_hash                 = {}
        connection_draining_timeout_sec = null
        description                     = null
        failover_policy                 = {}
        locality_lb_policy              = null
        outlier_detection               = {}
        port_name                       = null
        session_affinity                = null
        timeout_sec                     = 30
        log_config = {
          enable = false
        }
      }
    }

    compute_forwarding_rules = {
      fr-1 = {
        name                   = "fr-1"
        region                 = "us-central1"
        load_balancing_scheme  = "INTERNAL"
        backend_service        = "rbs-1"
        network                = "default"
        subnetwork             = "default"
        ip_protocol            = "TCP"
        ports                  = ["80"]
        project                = "test-project"
        description            = null
        ip_address             = null
        port_range             = null
        allow_global_access    = null
        all_ports              = null
        network_tier           = null
        service_label          = null
        is_mirroring_collector = null
        labels = {
          app = "test-app"
        }
      }
    }
  }

  # Verify Region Health Check
  assert {
    condition     = google_compute_region_health_check.compute_region_health_checks["rhc-1"].name == "test-rhc-1"
    error_message = "Region Health Check name incorrect"
  }

  assert {
    condition     = google_compute_region_health_check.compute_region_health_checks["rhc-1"].tcp_health_check[0].port == 80
    error_message = "Region Health Check port incorrect"
  }

  # Verify Region Backend Service
  assert {
    condition     = google_compute_region_backend_service.compute_region_backend_services["rbs-1"].name == "test-rbs-1"
    error_message = "Region Backend Service name incorrect"
  }

  assert {
    condition     = google_compute_region_backend_service.compute_region_backend_services["rbs-1"].load_balancing_scheme == "INTERNAL"
    error_message = "Region Backend Service scheme incorrect"
  }

  # Verify Forwarding Rule
  assert {
    condition     = google_compute_forwarding_rule.compute_forwarding_rules["fr-1"].name == "test-fr-1"
    error_message = "Forwarding Rule name incorrect"
  }

  assert {
    condition     = google_compute_forwarding_rule.compute_forwarding_rules["fr-1"].load_balancing_scheme == "INTERNAL"
    error_message = "Forwarding Rule scheme incorrect"
  }

  assert {
    condition     = google_compute_forwarding_rule.compute_forwarding_rules["fr-1"].labels["env"] == "test"
    error_message = "Forwarding Rule default label missing"
  }
}
