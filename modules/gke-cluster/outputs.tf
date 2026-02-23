output "backup_plan_ids" {
  description = "List of backup plan resource IDs."
  value       = [for bp in google_gke_backup_backup_plan.backup_plan : bp.id]
}

output "ca_certificate" {
  description = "Cluster ca certificate (base64 encoded)."
  value       = google_container_cluster.container_clusters.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "certificate_authority_config" {
  description = "Certificate authority configuration."
  value = var.enable_private_registry ? {
    fqdns      = local.registry_config.fqdns
    secret_uri = local.registry_config.secret_uri
  } : null
  sensitive = true
}

output "cluster_id" {
  description = "Cluster ID."
  value       = google_container_cluster.container_clusters.id
}

output "cluster_location" {
  description = "Cluster location."
  value       = google_container_cluster.container_clusters.location
}

output "cluster_name" {
  description = "Cluster name."
  value       = google_container_cluster.container_clusters.name
}

output "cluster_self_link" {
  description = "Cluster self-link URL."
  value       = google_container_cluster.container_clusters.self_link
}

output "endpoint" {
  description = "Cluster endpoint."
  value       = google_container_cluster.container_clusters.endpoint
  sensitive   = true
}

output "horizontal_pod_autoscaling_enabled" {
  description = "Whether horizontal pod autoscaling is enabled."
  value       = !local.addons_config.horizontal_pod_autoscaling.disabled
}

output "http_load_balancing_enabled" {
  description = "Whether http load balancing is enabled."
  value       = !local.addons_config.http_load_balancing.disabled
}

output "master_authorized_networks_config" {
  description = "Master authorized networks configuration."
  value       = google_container_cluster.container_clusters.master_authorized_networks_config
}

output "master_version" {
  description = "Current master kubernetes version."
  value       = google_container_cluster.container_clusters.master_version
}

output "network_policy_enabled" {
  description = "Whether network policy (Calico) is enabled."
  value       = !local.addons_config.network_policy_config.disabled
}

output "node_pools_names" {
  description = "List of node pools names."
  value       = [for pool in google_container_cluster.container_clusters.node_pool : pool.name]
}

output "peering_name" {
  description = "The name of the peering between this cluster and the Google owned VPC."
  value       = try(google_container_cluster.container_clusters.private_cluster_config[0].peering_name, null)
}

output "private_cluster_config" {
  description = "Private cluster configuration."
  value       = google_container_cluster.container_clusters.private_cluster_config
  sensitive   = true
}

output "pubsub_notification_topic" {
  description = "Pub/Sub topic for upgrade notifications if created."
  value       = try(google_pubsub_topic.notifications[0].name, null)
}
