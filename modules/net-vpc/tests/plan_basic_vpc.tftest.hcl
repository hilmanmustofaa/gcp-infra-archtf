run "plan_basic_vpc" {
  command = plan

  variables {
    networks = {
      dev_vpc = {
        project                 = "test-project"
        name                    = "dev-vpc"
        description             = "Development VPC network"
        auto_create_subnetworks = false
        routing_mode            = "REGIONAL"
        mtu                     = 1460
      }
    }

    subnetworks = {
      dev_subnet = {
        project                  = "test-project"
        name                     = "dev-subnet"
        network                  = "dev_vpc"
        description              = "Development subnet"
        ip_cidr_range            = "10.0.0.0/24"
        region                   = "us-central1"
        private_ip_google_access = true
        labels                   = {}
      }
    }

    compute_routes = {}
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

  # Verify network has correct name
  assert {
    condition     = output.networks["dev_vpc"].name == "dev-vpc"
    error_message = "Network name is incorrect"
  }

  # Verify subnet has correct CIDR
  assert {
    condition     = output.subnetworks["dev_subnet"].ip_cidr_range == "10.0.0.0/24"
    error_message = "Subnet CIDR is incorrect"
  }

  # Verify subnet has private Google access enabled
  assert {
    condition     = output.subnetworks["dev_subnet"].private_ip_google_access == true
    error_message = "Private Google access should be enabled"
  }
}
