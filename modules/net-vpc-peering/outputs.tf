output "network_peerings" {
  description = "The created network peerings."
  value       = google_compute_network_peering.compute_network_peerings
}

output "network_peerings_remote" {
  description = "The created remote network peerings."
  value       = google_compute_network_peering.compute_network_peerings_remote
}