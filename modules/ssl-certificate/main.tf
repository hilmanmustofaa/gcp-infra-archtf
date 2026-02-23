resource "google_compute_managed_ssl_certificate" "compute_managed_ssl_certificates" {
  provider = google
  for_each = var.compute_managed_ssl_certificates

  description = each.value.description
  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  managed {
    domains = each.value.managed.domains
  }
  type    = each.value.type
  project = each.value.project
}