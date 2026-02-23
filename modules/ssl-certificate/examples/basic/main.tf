module "ssl_certificate" {
  source = "../.."

  resource_prefix = "prod"
  join_separator  = "-"

  compute_managed_ssl_certificates = {
    example = {
      name        = "example"
      description = "Managed SSL certificate for example.com"
      project     = "my-project-id"
      type        = "MANAGED"
      managed = {
        domains = ["example.com"]
      }
    }
  }
}

# Outputs
output "certificate_id" {
  description = "The ID of the created certificate"
  value       = module.ssl_certificate.certificate_ids["example"]
}

output "certificate_self_link" {
  description = "The self link of the created certificate"
  value       = module.ssl_certificate.certificate_self_links["example"]
}

output "certificate_name" {
  description = "The name of the created certificate"
  value       = module.ssl_certificate.certificate_names["example"]
}
