run "plan_basic_peering" {
  command = plan

  variables {
    compute_network_peerings = {
      vpc_peering = {
        name                                = "vpc-peering"
        network                             = "projects/test-project/global/networks/vpc-a"
        peer_network                        = "projects/test-project/global/networks/vpc-b"
        export_custom_routes                = false
        import_custom_routes                = false
        export_subnet_routes_with_public_ip = false
        import_subnet_routes_with_public_ip = false
        stack_type                          = "IPV4_ONLY"
        peer_create_peering                 = false
      }
    }
  }

  # Verify peering is created
  assert {
    condition     = length(output.network_peerings) == 1
    error_message = "Expected 1 network peering to be created"
  }

  # Verify peering name
  assert {
    condition     = output.network_peerings["vpc_peering"].name == "vpc-peering"
    error_message = "Peering name is incorrect"
  }

  # Verify network references
  assert {
    condition     = output.network_peerings["vpc_peering"].network == "projects/test-project/global/networks/vpc-a"
    error_message = "Network reference is incorrect"
  }

  # Verify peer network references
  assert {
    condition     = output.network_peerings["vpc_peering"].peer_network == "projects/test-project/global/networks/vpc-b"
    error_message = "Peer network reference is incorrect"
  }

  # Verify custom routes are not exported
  assert {
    condition     = output.network_peerings["vpc_peering"].export_custom_routes == false
    error_message = "Export custom routes should be false"
  }

  # Verify custom routes are not imported
  assert {
    condition     = output.network_peerings["vpc_peering"].import_custom_routes == false
    error_message = "Import custom routes should be false"
  }

  # Verify stack type
  assert {
    condition     = output.network_peerings["vpc_peering"].stack_type == "IPV4_ONLY"
    error_message = "Stack type should be IPV4_ONLY"
  }

  # Verify no remote peering is created
  assert {
    condition     = length(output.network_peerings_remote) == 0
    error_message = "No remote peering should be created when peer_create_peering is false"
  }
}
