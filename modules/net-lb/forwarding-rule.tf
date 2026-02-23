resource "google_compute_forwarding_rule" "compute_forwarding_rules" {
  provider = google-beta
  for_each = var.compute_forwarding_rules

  name                   = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  is_mirroring_collector = each.value.is_mirroring_collector
  description            = each.value.description
  ip_address             = each.value.ip_address
  ip_protocol            = each.value.ip_protocol
  backend_service        = each.value.load_balancing_scheme == "INTERNAL" ? try(google_compute_region_backend_service.compute_region_backend_services[each.value.backend_service].id, null) : try(google_compute_backend_service.compute_backend_services[each.value.backend_service].id, null)
  load_balancing_scheme  = each.value.load_balancing_scheme
  network                = each.value.network
  port_range             = each.value.port_range
  ports                  = each.value.ports
  subnetwork             = each.value.subnetwork
  allow_global_access    = each.value.allow_global_access
  labels = merge(
    local.finops_labels_default,
    var.default_labels,
    try(each.value.labels, {}),
    {
      "resourcetype"   = "forwarding-rule"
      "gcp_asset_type" = "compute.googleapis.com/ForwardingRule"
    }
  )
  all_ports     = each.value.all_ports
  network_tier  = each.value.network_tier
  service_label = each.value.service_label
  region        = each.value.region
  project       = each.value.project
}
