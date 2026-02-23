output "node_pool_id" {
  description = "ID of the GKE node pool."
  value       = google_container_node_pool.container_node_pools.id
}

output "node_pool_name" {
  description = "Name of the GKE node pool."
  value       = google_container_node_pool.container_node_pools.name
}

output "node_pool_version" {
  description = "Kubernetes version of the node pool."
  value       = google_container_node_pool.container_node_pools.version
}
