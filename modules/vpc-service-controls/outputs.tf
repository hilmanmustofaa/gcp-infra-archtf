output "access_policy_name" {
  description = "The access policy name used as parent (created or referenced)."
  value       = local.policy_name
}

output "access_level_names" {
  description = "Map of logical key => full access level resource name."
  value       = { for k, v in google_access_context_manager_access_level.levels : k => v.name }
}

output "service_perimeter_names" {
  description = "Map of logical key => full service perimeter resource name."
  value       = { for k, v in google_access_context_manager_service_perimeter.perimeters : k => v.name }
}

output "finops_labels" {
  description = "FinOps label package for this module, to be merged with workspace-level defaults."
  value       = local.finops_labels
}
