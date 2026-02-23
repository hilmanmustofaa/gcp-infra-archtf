output "data_compute_subnetworks" {
  description = "Fetched data subnetworks from shared VPCs."
  value       = data.google_compute_subnetwork.compute_subnetworks
}

output "networks" {
  description = "Network resources created."
  value       = google_compute_network.network
}

output "policy_routes" {
  description = "Created policy-based routes."
  value       = google_network_connectivity_policy_based_route.policy_routes
}

output "routes" {
  description = "Created routes."
  value       = google_compute_route.compute_routes
}

output "subnetworks" {
  description = "Subnetwork resources created."
  value       = google_compute_subnetwork.subnetwork
}



