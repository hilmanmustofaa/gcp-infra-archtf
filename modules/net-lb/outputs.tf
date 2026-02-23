output "backend_services" {
  description = "The created backend services."
  value       = google_compute_backend_service.compute_backend_services
}

output "forwarding_rules" {
  description = "The created forwarding rules."
  value       = google_compute_forwarding_rule.compute_forwarding_rules
}

output "global_forwarding_rules" {
  description = "The created global forwarding rules."
  value       = google_compute_global_forwarding_rule.compute_global_forwarding_rules
}

output "health_checks" {
  description = "The created health checks."
  value       = google_compute_health_check.compute_health_checks
}

output "region_backend_services" {
  description = "The created regional backend services."
  value       = google_compute_region_backend_service.compute_region_backend_services
}

output "region_health_checks" {
  description = "The created regional health checks."
  value       = google_compute_region_health_check.compute_region_health_checks
}

output "target_https_proxies" {
  description = "The created target HTTPS proxies."
  value       = google_compute_target_https_proxy.compute_target_https_proxies
}

output "url_maps" {
  description = "The created URL maps."
  value       = google_compute_url_map.compute_url_maps
}