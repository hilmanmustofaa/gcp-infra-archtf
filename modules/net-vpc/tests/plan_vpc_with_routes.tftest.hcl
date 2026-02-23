run "plan_vpc_with_routes" {
  command = plan

  variables {
    networks = {
      staging_vpc = {
        project                 = "test-project"
        name                    = "staging-vpc"
        description             = "Staging VPC network"
        auto_create_subnetworks = false
        routing_mode            = "REGIONAL"
      }
    }

    subnetworks = {
      staging_subnet = {
        project                  = "test-project"
        name                     = "staging-subnet"
        network                  = "staging_vpc"
        description              = "Staging subnet"
        ip_cidr_range            = "10.2.0.0/24"
        region                   = "us-central1"
        private_ip_google_access = true
        labels                   = {}
      }
    }

    compute_routes = {
      internet_route = {
        name             = "internet-route"
        network          = "staging_vpc"
        dest_range       = "0.0.0.0/0"
        description      = "Route to internet gateway"
        priority         = 1000
        next_hop_gateway = "default-internet-gateway"
        project          = "test-project"
      }
    }
  }

  # Verify network is created
  assert {
    condition     = length(output.networks) == 1
    error_message = "Expected 1 network to be created"
  }

  # Verify subnet is created
  assert {
    condition     = length(output.subnetworks) == 1
    error_message = "Expected 1 subnet to be created"
  }

  # Verify route is created
  assert {
    condition     = length(output.routes) == 1
    error_message = "Expected 1 route to be created"
  }

  # Verify route has correct destination
  assert {
    condition     = output.routes["internet_route"].dest_range == "0.0.0.0/0"
    error_message = "Route destination is incorrect"
  }

  # Verify route has correct next hop
  assert {
    condition     = output.routes["internet_route"].next_hop_gateway == "default-internet-gateway"
    error_message = "Route next hop is incorrect"
  }

  # Verify route priority
  assert {
    condition     = output.routes["internet_route"].priority == 1000
    error_message = "Route priority is incorrect"
  }
}
