run "plan_basic" {
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
      nat-basic = {
        name    = "nat-basic"
        project = "test-project"
        region  = "us-central1"
        router  = "router-1"

        nat_ip_allocate_option             = "AUTO_ONLY"
        nat_ips                            = []
        source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

        log_config = {
          enable = true
          filter = "ERRORS_ONLY"
        }
      }
    }
  }

  assert {
    condition     = google_compute_router_nat.compute_router_nats["nat-basic"].name == "test-nat-basic"
    error_message = "NAT name should be test-nat-basic"
  }

  assert {
    condition     = google_compute_router_nat.compute_router_nats["nat-basic"].nat_ip_allocate_option == "AUTO_ONLY"
    error_message = "NAT IP allocation should be AUTO_ONLY"
  }
}
