output "id" {
  description = "Fully qualified job or service id."
  value       = var.create_job ? google_cloud_run_v2_job.job[0].id : google_cloud_run_v2_service.service[0].id
}

output "job" {
  description = "Cloud Run Job."
  value       = var.create_job ? google_cloud_run_v2_job.job[0] : null
}

output "service" {
  description = "Cloud Run Service."
  value       = var.create_job ? null : google_cloud_run_v2_service.service[0]
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
  value       = var.create_job ? null : google_cloud_run_v2_service.service[0].name
}

output "service_uri" {
  description = "Main URI in which the service is serving traffic."
  value       = var.create_job ? null : google_cloud_run_v2_service.service[0].uri
}

output "vpc_connector" {
  description = "VPC connector resource if created."
  value       = try(google_vpc_access_connector.connector[0].id, null)
}
