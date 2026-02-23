module "ssl_certificate" {
  source = "../.."

  resource_prefix = "prod"

  compute_managed_ssl_certificates = {
    web-cert = {
      name        = "web-cert"
      description = "Managed SSL certificate for web application"
      project     = "my-project-id"
      type        = "MANAGED"
      managed = {
        # Include both apex domain and www subdomain
        domains = [
          "example.com",
          "www.example.com"
        ]
      }
    }
  }
}

# Outputs
output "certificate_id" {
  description = "The ID of the web certificate"
  value       = module.ssl_certificate.certificate_ids["web-cert"]
}

output "certificate_self_link" {
  description = "The self link of the web certificate"
  value       = module.ssl_certificate.certificate_self_links["web-cert"]
}

output "all_certificates" {
  description = "All created certificates"
  value       = module.ssl_certificate.managed_ssl_certificates
}
