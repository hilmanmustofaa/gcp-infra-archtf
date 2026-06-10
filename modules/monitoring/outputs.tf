output "notification_channel_ids" {
  description = "Map of logical key => notification channel id."
  value = {
    for k, v in google_monitoring_notification_channel.channels : k => v.id
  }
}

output "alert_policy_ids" {
  description = "Map of logical key => alert policy id (name)."
  value = {
    for k, v in google_monitoring_alert_policy.policies : k => v.id
  }
}

output "uptime_check_ids" {
  description = "Map of logical key => uptime check config id."
  value = {
    for k, v in google_monitoring_uptime_check_config.uptime : k => v.uptime_check_id
  }
}

output "finops_labels" {
  description = "FinOps label package for this module, to be merged with workspace-level defaults."
  value       = local.finops_labels
}
