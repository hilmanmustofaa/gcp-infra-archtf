resource "google_compute_router" "compute_routers" {
  provider = google
  for_each = var.compute_routers

  name                          = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  network                       = each.value.network
  description                   = each.value.description
  encrypted_interconnect_router = each.value.encrypted_interconnect_router



  dynamic "bgp" {
    for_each = each.value.bgp != null ? [each.value.bgp] : []
    content {
      asn                = bgp.value.asn
      advertise_mode     = bgp.value.advertise_mode
      advertised_groups  = bgp.value.advertised_groups
      keepalive_interval = bgp.value.keepalive_interval

      dynamic "advertised_ip_ranges" {
        for_each = bgp.value.advertised_ip_ranges
        content {
          range       = advertised_ip_ranges.value.range
          description = advertised_ip_ranges.value.description
        }
      }
    }
  }
  region  = each.value.region
  project = each.value.project
}
