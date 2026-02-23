resource "google_compute_external_vpn_gateway" "compute_external_vpn_gateways" {
  provider = google
  for_each = var.compute_external_vpn_gateways

  name            = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  description     = each.value.description
  labels          = merge(var.default_labels, each.value.labels)
  redundancy_type = each.value.redundancy_type
  dynamic "interface" {
    for_each = each.value.interface
    content {
      id         = interface.value.id
      ip_address = interface.value.ip_address
    }
  }
  project = each.value.project
}

resource "google_compute_ha_vpn_gateway" "compute_ha_vpn_gateways" {
  provider = google
  for_each = var.compute_ha_vpn_gateways

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  network     = each.value.network
  description = each.value.description
  dynamic "vpn_interfaces" {
    for_each = each.value.vpn_interfaces
    content {
      id                      = vpn_interfaces.value.id
      ip_address              = vpn_interfaces.value.ip_address
      interconnect_attachment = vpn_interfaces.value.interconnect_attachment
    }
  }
  # Note: google_compute_ha_vpn_gateway does not support labels in the provider yet
  # labels = merge(var.default_labels, each.value.labels)
  region  = each.value.region
  project = each.value.project
}

resource "random_id" "vpn_tunnel_secret" {
  for_each    = { for k, v in var.compute_vpn_tunnels : k => v if v.shared_secret == null }
  byte_length = 16
}

resource "google_compute_vpn_tunnel" "compute_vpn_tunnels" {
  provider = google-beta
  for_each = var.compute_vpn_tunnels

  name                            = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  shared_secret                   = each.value.shared_secret != null ? each.value.shared_secret : random_id.vpn_tunnel_secret[each.key].b64_url
  description                     = each.value.description
  vpn_gateway                     = each.value.vpn_gateway
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway           = each.value.peer_external_gateway
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  peer_gcp_gateway                = each.value.peer_gcp_gateway
  router                          = each.value.router
  peer_ip                         = each.value.peer_ip
  ike_version                     = each.value.ike_version
  local_traffic_selector          = each.value.local_traffic_selector
  remote_traffic_selector         = each.value.remote_traffic_selector
  labels                          = merge(var.default_labels, each.value.labels)
  region                          = each.value.region
  project                         = each.value.project
}
