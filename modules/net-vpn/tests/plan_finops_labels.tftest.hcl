run "plan_finops_labels" {
  command = plan

  variables {
    default_labels = {
      environment = "dev"
      team        = "network"
    }

    compute_external_vpn_gateways = {
      external_gw = {
        name            = "external-gw"
        redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
        interface = [
          {
            id         = 0
            ip_address = "8.8.8.8"
          }
        ]
        project = "test-project"
        labels = {
          cost-center = "1234"
        }
      }
    }

    compute_vpn_tunnels = {
      tunnel1 = {
        name                  = "tunnel-1"
        shared_secret         = "secret"
        vpn_gateway           = "projects/test-project/regions/us-central1/targetVpnGateways/vpn-gw"
        peer_external_gateway = "projects/test-project/global/externalVpnGateways/external-gw"
        region                = "us-central1"
        project               = "test-project"
        labels = {
          application = "app1"
        }
      }
    }
  }

  # Verify External Gateway labels
  assert {
    condition     = output.external_vpn_gateways["external_gw"].labels["environment"] == "dev"
    error_message = "External Gateway should have default label environment=dev"
  }

  assert {
    condition     = output.external_vpn_gateways["external_gw"].labels["team"] == "network"
    error_message = "External Gateway should have default label team=network"
  }

  assert {
    condition     = output.external_vpn_gateways["external_gw"].labels["cost-center"] == "1234"
    error_message = "External Gateway should have specific label cost-center=1234"
  }

  # Verify VPN Tunnel labels
  assert {
    condition     = output.vpn_tunnels["tunnel1"].labels["environment"] == "dev"
    error_message = "VPN Tunnel should have default label environment=dev"
  }

  assert {
    condition     = output.vpn_tunnels["tunnel1"].labels["team"] == "network"
    error_message = "VPN Tunnel should have default label team=network"
  }

  assert {
    condition     = output.vpn_tunnels["tunnel1"].labels["application"] == "app1"
    error_message = "VPN Tunnel should have specific label application=app1"
  }
}
