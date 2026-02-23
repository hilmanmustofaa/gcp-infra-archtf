output "ca_certificate" {
  description = "The cluster CA certificate (base64 encoded)."
  value       = google_container_cluster.autopilot_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "endpoint" {
  description = "The IP address of the cluster master."
  value       = google_container_cluster.autopilot_cluster.endpoint
}

output "id" {
  description = "The unique identifier of the cluster."
  value       = google_container_cluster.autopilot_cluster.id
}

output "location" {
  description = "The location of the cluster."
  value       = google_container_cluster.autopilot_cluster.location
}

output "master_version" {
  description = "The current version of the master."
  value       = google_container_cluster.autopilot_cluster.master_version
}

output "name" {
  description = "The name of the cluster."
  value       = google_container_cluster.autopilot_cluster.name
}

output "self_link" {
  description = "The server-defined URL for the cluster."
  value       = google_container_cluster.autopilot_cluster.self_link
}
