run "plan_hybrid_spoke" {
  command = plan

  variables {
    project_id          = "test-project"
    ncc_hub_name        = "test-hub"
    ncc_hub_description = "Test NCC Hub for Hybrid"

    spoke_labels = {
      environment = "prod"
    }

    hybrid_spokes = {
      vpn-spoke = {
        location                   = "us-central1"
        type                       = "vpn"
        uris                       = ["https://www.googleapis.com/compute/v1/projects/test-project/regions/us-central1/vpnTunnels/tunnel-1"]
        site_to_site_data_transfer = true
        description                = "VPN tunnel spoke"
        labels = {
          connectivity = "vpn"
        }
      }
      interconnect-spoke = {
        location                   = "us-west1"
        type                       = "interconnect"
        uris                       = ["https://www.googleapis.com/compute/v1/projects/test-project/regions/us-west1/interconnectAttachments/attachment-1"]
        site_to_site_data_transfer = false
        description                = "Interconnect spoke"
        labels = {
          connectivity = "interconnect"
        }
      }
    }
  }

  # Verify Hub
  assert {
    condition     = google_network_connectivity_hub.hub.name == "test-hub"
    error_message = "Hub name should be test-hub"
  }

  # Verify VPN Spoke
  assert {
    condition     = google_network_connectivity_spoke.hybrid_spoke["vpn-spoke"].name == "vpn-spoke"
    error_message = "VPN spoke name incorrect"
  }

  assert {
    condition     = google_network_connectivity_spoke.hybrid_spoke["vpn-spoke"].location == "us-central1"
    error_message = "VPN spoke location incorrect"
  }

  assert {
    condition     = google_network_connectivity_spoke.hybrid_spoke["vpn-spoke"].labels["environment"] == "prod"
    error_message = "VPN spoke should have default label environment=prod"
  }

  assert {
    condition     = google_network_connectivity_spoke.hybrid_spoke["vpn-spoke"].labels["connectivity"] == "vpn"
    error_message = "VPN spoke should have specific label connectivity=vpn"
  }

  # Verify Interconnect Spoke
  assert {
    condition     = google_network_connectivity_spoke.hybrid_spoke["interconnect-spoke"].name == "interconnect-spoke"
    error_message = "Interconnect spoke name incorrect"
  }

  assert {
    condition     = google_network_connectivity_spoke.hybrid_spoke["interconnect-spoke"].labels["connectivity"] == "interconnect"
    error_message = "Interconnect spoke should have specific label connectivity=interconnect"
  }
}
