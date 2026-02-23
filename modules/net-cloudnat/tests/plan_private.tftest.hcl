run "plan_private" {
  command = plan

  variables {
    resource_prefix = "test"

    router_lookup = {
      router-1 = {
        name = "router-1"
      }
    }

    network_lookup = {
      subnet-1 = {
        self_link = "projects/test-project/regions/us-central1/subnetworks/subnet-1"
      }
    }

    nat_ip_lookup = {}

    compute_router_nats = {
      nat-private = {
        name    = "nat-private"
        project = "test-project"
        region  = "us-central1"
        router  = "router-1"
        type    = "PRIVATE"

        nat_ip_allocate_option             = "AUTO_ONLY"
        nat_ips                            = []
        source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

        subnetwork = {
          subnet-1 = {
            name                    = "subnet-1"
            source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
          }
        }

        log_config = {
          enable = true
          filter = "ERRORS_ONLY"
        }

        rules = {
          "100" = {
            match = "destination.ip_range == '192.168.1.0/24'"
            action = {
              source_nat_active_ips = []
            }
          }
        }
      }
    }
  }

  assert {
    condition     = google_compute_router_nat.compute_router_nats["nat-private"].type == "PRIVATE"
    error_message = "NAT type should be PRIVATE"
  }

  assert {
    condition     = google_compute_router_nat.compute_router_nats["nat-private"].source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS"
    error_message = "Source subnetwork IP ranges should be LIST_OF_SUBNETWORKS"
  }
}
