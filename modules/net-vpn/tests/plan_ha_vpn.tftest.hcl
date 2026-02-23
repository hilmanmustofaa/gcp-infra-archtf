run "plan_ha_vpn" {
  command = plan

  variables {
    compute_ha_vpn_gateways = {
      ha_gw = {
        name    = "ha-vpn-gw"
        network = "projects/test-project/global/networks/vpc-1"
        region  = "us-central1"
        project = "test-project"
        vpn_interfaces = [
          {
            id = 0
          },
          {
            id = 1
          }
        ]
      }
    }

    compute_vpn_tunnels = {
      ha_tunnel_0 = {
        name                  = "ha-tunnel-0"
        shared_secret         = "secret"
        vpn_gateway           = "projects/test-project/regions/us-central1/vpnGateways/ha-vpn-gw"
        vpn_gateway_interface = 0
        peer_external_gateway = "projects/test-project/global/externalVpnGateways/peer-gw"
        router                = "projects/test-project/regions/us-central1/routers/router-1"
        ike_version           = 2
        region                = "us-central1"
        project               = "test-project"
      }
      ha_tunnel_1 = {
        name                  = "ha-tunnel-1"
        shared_secret         = "secret"
        vpn_gateway           = "projects/test-project/regions/us-central1/vpnGateways/ha-vpn-gw"
        vpn_gateway_interface = 1
        peer_external_gateway = "projects/test-project/global/externalVpnGateways/peer-gw"
        router                = "projects/test-project/regions/us-central1/routers/router-1"
        ike_version           = 2
        region                = "us-central1"
        project               = "test-project"
      }
    }
  }

  # Verify HA VPN Gateway
  assert {
    condition     = length(output.ha_vpn_gateways) == 1
    error_message = "Expected 1 HA VPN gateway"
  }

  assert {
    condition     = output.ha_vpn_gateways["ha_gw"].name == "ha-vpn-gw"
    error_message = "HA VPN Gateway name is incorrect"
  }

  assert {
    condition     = length(output.ha_vpn_gateways["ha_gw"].vpn_interfaces) == 2
    error_message = "HA VPN Gateway should have 2 interfaces"
  }

  # Verify Tunnels
  assert {
    condition     = length(output.vpn_tunnels) == 2
    error_message = "Expected 2 VPN tunnels"
  }

  assert {
    condition     = output.vpn_tunnels["ha_tunnel_0"].vpn_gateway_interface == 0
    error_message = "Tunnel 0 should be on interface 0"
  }

  assert {
    condition     = output.vpn_tunnels["ha_tunnel_1"].vpn_gateway_interface == 1
    error_message = "Tunnel 1 should be on interface 1"
  }

  assert {
    condition     = output.vpn_tunnels["ha_tunnel_0"].ike_version == 2
    error_message = "IKE version should be 2"
  }
}
