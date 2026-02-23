output "id" {
  description = "Fully qualified policy id."
  value       = try(google_dns_response_policy.default[0].id, null)
}

output "name" {
  description = "Policy name."
  value       = local.policy_name
}

output "policy" {
  description = "Policy resource."
  value       = try(google_dns_response_policy.default[0], null)
}
