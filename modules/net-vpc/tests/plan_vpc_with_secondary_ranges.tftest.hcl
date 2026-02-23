run "plan_vpc_with_secondary_ranges" {
  command = plan

  variables {
    networks = {
      gke_vpc = {
        project                 = "test-project"
        name                    = "gke-vpc"
        description             = "VPC for GKE cluster"
        auto_create_subnetworks = false
        routing_mode            = "REGIONAL"
        mtu                     = 1460
      }
    }

    subnetworks = {
      gke_subnet = {
        project                  = "test-project"
        name                     = "gke-subnet"
        network                  = "gke_vpc"
        description              = "GKE subnet with secondary ranges"
        ip_cidr_range            = "10.3.0.0/24"
        region                   = "us-central1"
        private_ip_google_access = true
        secondary_ip_range = {
          pods = {
            range_name    = "gke-pods"
            ip_cidr_range = "10.4.0.0/16"
          }
          services = {
            range_name    = "gke-services"
            ip_cidr_range = "10.5.0.0/20"
          }
        }
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

  # Verify subnet has secondary ranges
  assert {
    condition     = length(output.subnetworks["gke_subnet"].secondary_ip_range) == 2
    error_message = "Expected 2 secondary IP ranges"
  }

  # Verify pods secondary range
  assert {
    condition = anytrue([
      for range in output.subnetworks["gke_subnet"].secondary_ip_range :
      range.range_name == "gke-pods" && range.ip_cidr_range == "10.4.0.0/16"
    ])
    error_message = "Pods secondary range is incorrect"
  }

  # Verify services secondary range
  assert {
    condition = anytrue([
      for range in output.subnetworks["gke_subnet"].secondary_ip_range :
      range.range_name == "gke-services" && range.ip_cidr_range == "10.5.0.0/20"
    ])
    error_message = "Services secondary range is incorrect"
  }
}
