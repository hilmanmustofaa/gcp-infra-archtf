run "plan_router_appliance_spoke" {
  command = plan

  variables {
    project_id          = "test-project"
    ncc_hub_name        = "test-hub"
    ncc_hub_description = "Test NCC Hub for Router Appliances"

    spoke_labels = {
      type = "router-appliance"
    }

    router_appliance_spokes = {
      ra-spoke-1 = {
        location = "us-central1"
        instances = [
          {
            virtual_machine = "https://www.googleapis.com/compute/v1/projects/test-project/zones/us-central1-a/instances/router-1"
            ip_address      = "10.0.0.10"
          },
          {
            virtual_machine = "https://www.googleapis.com/compute/v1/projects/test-project/zones/us-central1-b/instances/router-2"
            ip_address      = "10.0.0.11"
          }
        ]
        site_to_site_data_transfer = true
        description                = "Router appliance spoke"
        labels = {
          ha = "enabled"
        }
      }
    }
  }

  # Verify Hub
  assert {
    condition     = google_network_connectivity_hub.hub.name == "test-hub"
    error_message = "Hub name should be test-hub"
  }

  # Verify Router Appliance Spoke
  assert {
    condition     = google_network_connectivity_spoke.router_appliance_spoke["ra-spoke-1"].name == "ra-spoke-1"
    error_message = "Router appliance spoke name incorrect"
  }

  assert {
    condition     = google_network_connectivity_spoke.router_appliance_spoke["ra-spoke-1"].location == "us-central1"
    error_message = "Router appliance spoke location incorrect"
  }

  assert {
    condition     = google_network_connectivity_spoke.router_appliance_spoke["ra-spoke-1"].labels["type"] == "router-appliance"
    error_message = "Router appliance spoke should have default label type=router-appliance"
  }

  assert {
    condition     = google_network_connectivity_spoke.router_appliance_spoke["ra-spoke-1"].labels["ha"] == "enabled"
    error_message = "Router appliance spoke should have specific label ha=enabled"
  }

  # Verify instances are configured
  assert {
    condition     = length(google_network_connectivity_spoke.router_appliance_spoke["ra-spoke-1"].linked_router_appliance_instances) > 0
    error_message = "Router appliance spoke should have instances configured"
  }
}
