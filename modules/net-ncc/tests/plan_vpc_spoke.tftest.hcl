run "plan_vpc_spoke" {
  command = plan

  variables {
    project_id          = "test-project"
    ncc_hub_name        = "test-hub"
    ncc_hub_description = "Test NCC Hub"

    ncc_hub_labels = {
      environment = "test"
      managed_by  = "terraform"
    }

    spoke_labels = {
      team = "network"
    }

    vpc_spokes = {
      spoke-1 = {
        uri         = "projects/test-project/global/networks/vpc-1"
        description = "VPC spoke 1"
        labels = {
          app = "web"
        }
      }
      spoke-2 = {
        uri         = "projects/test-project/global/networks/vpc-2"
        description = "VPC spoke 2"
        labels = {
          app = "database"
        }
      }
    }
  }

  # Verify NCC Hub
  assert {
    condition     = google_network_connectivity_hub.hub.name == "test-hub"
    error_message = "Hub name should be test-hub"
  }

  assert {
    condition     = google_network_connectivity_hub.hub.labels["environment"] == "test"
    error_message = "Hub should have environment=test label"
  }

  # Verify VPC Spoke 1
  assert {
    condition     = google_network_connectivity_spoke.vpc_spoke["spoke-1"].name == "spoke-1"
    error_message = "VPC spoke 1 name incorrect"
  }

  assert {
    condition     = google_network_connectivity_spoke.vpc_spoke["spoke-1"].labels["team"] == "network"
    error_message = "VPC spoke 1 should have default label team=network"
  }

  assert {
    condition     = google_network_connectivity_spoke.vpc_spoke["spoke-1"].labels["app"] == "web"
    error_message = "VPC spoke 1 should have specific label app=web"
  }

  # Verify VPC Spoke 2
  assert {
    condition     = google_network_connectivity_spoke.vpc_spoke["spoke-2"].labels["team"] == "network"
    error_message = "VPC spoke 2 should have default label team=network"
  }

  assert {
    condition     = google_network_connectivity_spoke.vpc_spoke["spoke-2"].labels["app"] == "database"
    error_message = "VPC spoke 2 should have specific label app=database"
  }
}
