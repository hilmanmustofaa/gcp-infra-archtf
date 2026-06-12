output "topic_ids" {
  description = "Map of logical key => Pub/Sub topic id (projects/.../topics/...)."
  value       = { for k, v in google_pubsub_topic.topics : k => v.id }
}

output "topic_names" {
  description = "Map of logical key => Pub/Sub topic short name."
  value       = { for k, v in google_pubsub_topic.topics : k => v.name }
}

output "subscription_ids" {
  description = "Map of logical key => Pub/Sub subscription id."
  value       = { for k, v in google_pubsub_subscription.subscriptions : k => v.id }
}

output "subscription_names" {
  description = "Map of logical key => Pub/Sub subscription short name."
  value       = { for k, v in google_pubsub_subscription.subscriptions : k => v.name }
}

output "finops_labels" {
  description = "FinOps label package for this module, to be merged with workspace-level defaults."
  value       = local.finops_labels
}
