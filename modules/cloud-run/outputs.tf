output "id" {
  description = "Fully qualified service id."
  value       = google_cloud_run_service.service.id
}

output "service" {
  description = "Cloud Run service."
  value       = google_cloud_run_service.service
}

output "service_account" {
  description = "Service account resource."
  value       = try(google_service_account.service_account[0], null)
}

output "service_account_email" {
  description = "Service account email."
  value       = local.service_account_email
}

output "service_account_iam_email" {
  description = "Service account email."
  value = join("", [
    "serviceAccount:",
    local.service_account_email == null ? "" : local.service_account_email
  ])
}

output "service_name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_service.service.name
}


output "vpc_connector" {
  description = "VPC connector resource if created."
  value       = try(google_vpc_access_connector.connector[0].id, null)
}
