resource "google_compute_target_https_proxy" "compute_target_https_proxies" {
  provider = google
  for_each = var.compute_target_https_proxies

  name             = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  url_map          = google_compute_url_map.compute_url_maps[each.value.url_map].self_link
  description      = try(each.value.description, null)
  ssl_certificates = try(each.value.ssl_certificates, null)
  project          = each.value.project
}
