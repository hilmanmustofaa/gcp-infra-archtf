resource "google_compute_url_map" "compute_url_maps" {
  provider = google
  for_each = var.compute_url_maps

  name            = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  description     = each.value.description
  default_service = google_compute_backend_service.compute_backend_services[each.value.default_service].self_link
  dynamic "host_rule" {
    for_each = each.value.host_rule

    content {
      description  = host_rule.value.description
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }
  dynamic "path_matcher" {
    for_each = each.value.path_matcher
    content {
      default_service = google_compute_backend_service.compute_backend_services[path_matcher.value.default_service].self_link
      description     = path_matcher.value.description
      name            = path_matcher.value.name
    }
  }
  project = each.value.project
}
