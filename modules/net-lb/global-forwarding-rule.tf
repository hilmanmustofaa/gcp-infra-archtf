resource "google_compute_global_forwarding_rule" "compute_global_forwarding_rules" {
  provider = google-beta
  for_each = var.compute_global_forwarding_rules

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  target      = google_compute_target_https_proxy.compute_target_https_proxies[each.value.target].self_link
  description = each.value.description
  ip_address  = each.value.ip_address
  ip_protocol = each.value.ip_protocol
  labels = merge(
    local.finops_labels_default,
    var.default_labels,
    try(each.value.labels, {}),
    {
      "resourcetype"   = "global-forwarding-rule"
      "gcp_asset_type" = "compute.googleapis.com/GlobalForwardingRule"
    }
  )
  load_balancing_scheme = each.value.load_balancing_scheme
  network               = each.value.network
  port_range            = each.value.port_range
  project               = each.value.project
}
