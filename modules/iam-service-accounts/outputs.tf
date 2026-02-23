output "email" {
  description = "Service account email."
  value       = local.resource_email_static
  depends_on = [
    google_service_account.service_accounts,
    google_service_account_iam_binding.bindings,
    google_service_account_iam_member.bindings,
  ]
}

output "finops_labels" {
  description = "FinOps label package for this module (module + labels var), to be merged with workspace-level defaults."
  value       = local.finops_labels
}

output "iam_email" {
  description = "IAM-format service account email."
  value       = local.resource_iam_email_static
  depends_on = [
    google_service_account.service_accounts,
    google_service_account_iam_binding.bindings,
    google_service_account_iam_member.bindings,
  ]
}

output "id" {
  description = "Fully qualified service account id."
  value       = local.service_account_email
  depends_on = [
    google_service_account.service_accounts,
    google_service_account_iam_binding.bindings,
    google_service_account_iam_member.bindings,
  ]
}

output "key" {
  description = "Service account key, if one was created."
  sensitive   = true
  value = try(
    google_service_account_key.keys[0],
    null,
  )
}

output "name" {
  description = "Service account name."
  value       = var.account_id
  depends_on = [
    google_service_account.service_accounts,
    google_service_account_iam_binding.bindings,
    google_service_account_iam_member.bindings,
  ]
}

output "service_account" {
  description = "Service account resource."
  value = (
    var.service_account_create
    ? try(google_service_account.service_accounts[0], null)
    : try(data.google_service_account.service_accounts[0], null)
  )
}
