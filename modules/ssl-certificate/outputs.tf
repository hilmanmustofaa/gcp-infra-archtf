output "certificate_ids" {
  description = "Map of certificate IDs."
  value = {
    for k, v in google_compute_managed_ssl_certificate.compute_managed_ssl_certificates : k => v.id
  }
}

output "certificate_names" {
  description = "Map of certificate names."
  value = {
    for k, v in google_compute_managed_ssl_certificate.compute_managed_ssl_certificates : k => v.name
  }
}

output "certificate_self_links" {
  description = "Map of certificate self links."
  value = {
    for k, v in google_compute_managed_ssl_certificate.compute_managed_ssl_certificates : k => v.self_link
  }
}

output "managed_ssl_certificates" {
  description = "The created managed SSL certificates."
  value       = google_compute_managed_ssl_certificate.compute_managed_ssl_certificates
}
