resource "google_compute_network_peering" "compute_network_peerings" {
  provider = google
  for_each = var.compute_network_peerings

  name                                = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  network                             = each.value.network
  peer_network                        = each.value.peer_network
  export_custom_routes                = each.value.export_custom_routes
  import_custom_routes                = each.value.import_custom_routes
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  stack_type                          = each.value.stack_type
}

resource "google_compute_network_peering" "compute_network_peerings_remote" {
  provider = google
  for_each = { for k, v in var.compute_network_peerings : k => v if v.peer_create_peering }

  name                                = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name, "remote"]) : "${each.value.name}-remote"
  network                             = each.value.peer_network
  peer_network                        = each.value.network
  export_custom_routes                = each.value.export_custom_routes
  import_custom_routes                = each.value.import_custom_routes
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  stack_type                          = each.value.stack_type
  depends_on                          = [google_compute_network_peering.compute_network_peerings]
}