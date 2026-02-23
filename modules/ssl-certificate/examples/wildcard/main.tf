module "ssl_certificate" {
  source = "../.."

  resource_prefix = "prod"

  compute_managed_ssl_certificates = {
    wildcard-cert = {
      name        = "wildcard-cert"
      description = "Wildcard SSL certificate for all subdomains"
      project     = "my-project-id"
      type        = "MANAGED"
      managed = {
        # Wildcard certificate covers all subdomains
        # Note: Does NOT cover the apex domain (example.com)
        domains = [
          "*.example.com"
        ]
      }
    }
    apex-and-wildcard = {
      name        = "apex-and-wildcard"
      description = "Certificate covering both apex and all subdomains"
      project     = "my-project-id"
      type        = "MANAGED"
      managed = {
        # Include both apex domain and wildcard for complete coverage
        domains = [
          "example.com",
          "*.example.com"
        ]
      }
    }
  }
}

# Outputs
output "wildcard_certificate_id" {
  description = "The ID of the wildcard certificate"
  value       = module.ssl_certificate.certificate_ids["wildcard-cert"]
}

output "apex_and_wildcard_certificate_id" {
  description = "The ID of the apex and wildcard certificate"
  value       = module.ssl_certificate.certificate_ids["apex-and-wildcard"]
}

output "all_certificate_names" {
  description = "All certificate names"
  value       = module.ssl_certificate.certificate_names
}
