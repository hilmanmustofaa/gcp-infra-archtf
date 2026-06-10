output "brand_name" {
  description = "Resource name of the IAP brand, if created (else null)."
  value       = local.brand_name
}

output "oauth_client_id" {
  description = "OAuth client ID, if a client was created (else null)."
  value       = var.create_client ? google_iap_client.client[0].client_id : null
}

output "oauth_client_secret" {
  description = "OAuth client secret, if a client was created (else null)."
  value       = var.create_client ? google_iap_client.client[0].secret : null
  sensitive   = true
}

output "tunnel_instance_bindings" {
  description = "Map of created IAP tunnel instance IAM bindings."
  value       = google_iap_tunnel_instance_iam_binding.tunnel_bindings
}

output "web_backend_bindings" {
  description = "Map of created IAP web backend service IAM bindings."
  value       = google_iap_web_backend_service_iam_binding.web_backend_bindings
}
