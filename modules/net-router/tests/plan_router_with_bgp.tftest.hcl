run "plan_router_with_bgp" {
  command = plan

  variables {
    resource_prefix = "prod"

    compute_routers = {
      bgp-router = {
        name                          = "bgp-router"
        network                       = "projects/test-project/global/networks/vpc-1"
        region                        = "us-central1"
        project                       = "test-project"
        description                   = "BGP router for VPN"
        encrypted_interconnect_router = false
        bgp = {
          asn                = 64512
          advertise_mode     = "CUSTOM"
          advertised_groups  = ["ALL_SUBNETS"]
          keepalive_interval = 20
          advertised_ip_ranges = [
            {
              range       = "10.0.0.0/8"
              description = "Private network range"
            },
            {
              range       = "192.168.0.0/16"
              description = "Additional private range"
            }
          ]
        }
      }
    }
  }

  # Verify Router
  assert {
    condition     = google_compute_router.compute_routers["bgp-router"].name == "prod-bgp-router"
    error_message = "BGP router name incorrect"
  }

  # Verify BGP Configuration
  assert {
    condition     = google_compute_router.compute_routers["bgp-router"].bgp[0].asn == 64512
    error_message = "BGP ASN incorrect"
  }

  assert {
    condition     = google_compute_router.compute_routers["bgp-router"].bgp[0].advertise_mode == "CUSTOM"
    error_message = "BGP advertise mode incorrect"
  }

  assert {
    condition     = google_compute_router.compute_routers["bgp-router"].bgp[0].keepalive_interval == 20
    error_message = "BGP keepalive interval incorrect"
  }

  # Verify Advertised IP Ranges
  assert {
    condition     = length(google_compute_router.compute_routers["bgp-router"].bgp[0].advertised_ip_ranges) == 2
    error_message = "Should have 2 advertised IP ranges"
  }
}
