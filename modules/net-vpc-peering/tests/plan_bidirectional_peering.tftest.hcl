run "plan_bidirectional_peering" {
  command = plan

  variables {
    compute_network_peerings = {
      vpc_peering_bidirectional = {
        name                                = "vpc-peering-bidirectional"
        network                             = "projects/test-project/global/networks/vpc-primary"
        peer_network                        = "projects/test-project/global/networks/vpc-secondary"
        export_custom_routes                = true
        import_custom_routes                = true
        export_subnet_routes_with_public_ip = false
        import_subnet_routes_with_public_ip = false
        stack_type                          = "IPV4_ONLY"
        peer_create_peering                 = true
      }
    }
  }

  # Verify local peering is created
  assert {
    condition     = length(output.network_peerings) == 1
    error_message = "Expected 1 local network peering to be created"
  }

  # Verify remote peering is created
  assert {
    condition     = length(output.network_peerings_remote) == 1
    error_message = "Expected 1 remote network peering to be created"
  }

  # Verify local peering name
  assert {
    condition     = output.network_peerings["vpc_peering_bidirectional"].name == "vpc-peering-bidirectional"
    error_message = "Local peering name is incorrect"
  }

  # Verify remote peering name
  assert {
    condition     = output.network_peerings_remote["vpc_peering_bidirectional"].name == "vpc-peering-bidirectional-remote"
    error_message = "Remote peering name is incorrect"
  }

  # Verify local peering network references
  assert {
    condition = (
      output.network_peerings["vpc_peering_bidirectional"].network == "projects/test-project/global/networks/vpc-primary" &&
      output.network_peerings["vpc_peering_bidirectional"].peer_network == "projects/test-project/global/networks/vpc-secondary"
    )
    error_message = "Local peering network references are incorrect"
  }

  # Verify remote peering network references (reversed)
  assert {
    condition = (
      output.network_peerings_remote["vpc_peering_bidirectional"].network == "projects/test-project/global/networks/vpc-secondary" &&
      output.network_peerings_remote["vpc_peering_bidirectional"].peer_network == "projects/test-project/global/networks/vpc-primary"
    )
    error_message = "Remote peering network references should be reversed"
  }

  # Verify custom routes are exported on both sides
  assert {
    condition = (
      output.network_peerings["vpc_peering_bidirectional"].export_custom_routes == true &&
      output.network_peerings_remote["vpc_peering_bidirectional"].export_custom_routes == true
    )
    error_message = "Custom routes should be exported on both sides"
  }

  # Verify custom routes are imported on both sides
  assert {
    condition = (
      output.network_peerings["vpc_peering_bidirectional"].import_custom_routes == true &&
      output.network_peerings_remote["vpc_peering_bidirectional"].import_custom_routes == true
    )
    error_message = "Custom routes should be imported on both sides"
  }
}
