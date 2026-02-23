run "plan_peering_with_custom_routes" {
  command = plan

  variables {
    compute_network_peerings = {
      vpc_peering_custom = {
        name                                = "vpc-peering-custom"
        network                             = "projects/test-project/global/networks/vpc-hub"
        peer_network                        = "projects/test-project/global/networks/vpc-spoke"
        export_custom_routes                = true
        import_custom_routes                = false
        export_subnet_routes_with_public_ip = true
        import_subnet_routes_with_public_ip = false
        stack_type                          = "IPV4_IPV6"
        peer_create_peering                 = false
      }
    }

    resource_prefix = "prod"
    join_separator  = "-"
  }

  # Verify peering is created
  assert {
    condition     = length(output.network_peerings) == 1
    error_message = "Expected 1 network peering to be created"
  }

  # Verify peering name with prefix
  assert {
    condition     = output.network_peerings["vpc_peering_custom"].name == "prod-vpc-peering-custom"
    error_message = "Peering name with prefix is incorrect"
  }

  # Verify custom routes export is enabled
  assert {
    condition     = output.network_peerings["vpc_peering_custom"].export_custom_routes == true
    error_message = "Export custom routes should be enabled"
  }

  # Verify custom routes import is disabled
  assert {
    condition     = output.network_peerings["vpc_peering_custom"].import_custom_routes == false
    error_message = "Import custom routes should be disabled"
  }

  # Verify subnet routes with public IP export is enabled
  assert {
    condition     = output.network_peerings["vpc_peering_custom"].export_subnet_routes_with_public_ip == true
    error_message = "Export subnet routes with public IP should be enabled"
  }

  # Verify subnet routes with public IP import is disabled
  assert {
    condition     = output.network_peerings["vpc_peering_custom"].import_subnet_routes_with_public_ip == false
    error_message = "Import subnet routes with public IP should be disabled"
  }

  # Verify stack type is dual stack
  assert {
    condition     = output.network_peerings["vpc_peering_custom"].stack_type == "IPV4_IPV6"
    error_message = "Stack type should be IPV4_IPV6 for dual stack"
  }

  # Verify network references
  assert {
    condition = (
      output.network_peerings["vpc_peering_custom"].network == "projects/test-project/global/networks/vpc-hub" &&
      output.network_peerings["vpc_peering_custom"].peer_network == "projects/test-project/global/networks/vpc-spoke"
    )
    error_message = "Network references are incorrect"
  }
}
