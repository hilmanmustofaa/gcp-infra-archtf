output "compute_disks" {
  description = "Map of compute disks created."
  value       = google_compute_disk.compute_disks
  sensitive   = true
}

output "compute_images" {
  description = "Map of data source compute images used."
  value       = data.google_compute_image.compute_images
}

output "compute_instance_templates" {
  description = "Map of compute instance templates created."
  value       = google_compute_instance_template.compute_instance_templates
}

output "compute_instances" {
  description = "Map of compute instances created."
  value       = google_compute_instance.compute_instances
  sensitive   = true
}

output "resource_policies" {
  description = "Map of resource policies created."
  value       = google_compute_resource_policy.compute_resource_policies
}

output "snapshot_schedule_attachments" {
  description = "Map of resource policy attachments created."
  value       = google_compute_disk_resource_policy_attachment.snapshot_schedule_attachment
}

output "tls_private_keys" {
  description = "The input TLS private keys."
  value       = var.tls_private_keys
  sensitive   = true
}


