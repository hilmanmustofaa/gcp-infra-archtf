output "secret_ids" {
  description = "Map of logical key => secret_id (short ID) for each created secret."
  value = {
    for k, v in google_secret_manager_secret.secrets : k => v.secret_id
  }
}

output "secret_names" {
  description = "Map of logical key => fully-qualified secret resource name (projects/.../secrets/...)."
  value = {
    for k, v in google_secret_manager_secret.secrets : k => v.name
  }
}

output "secrets" {
  description = "Map of created secret resources."
  value       = google_secret_manager_secret.secrets
}

output "finops_labels" {
  description = "FinOps label package for this module, to be merged with workspace-level defaults."
  value       = local.finops_labels
}
