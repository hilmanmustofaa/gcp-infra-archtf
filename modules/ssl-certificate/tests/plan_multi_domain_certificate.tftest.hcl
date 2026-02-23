run "plan_multi_domain_certificate" {
  command = plan

  variables {
    resource_prefix = "staging"

    compute_managed_ssl_certificates = {
      web-cert = {
        name        = "web-cert"
        description = "Certificate for web application with multiple domains"
        project     = "test-project"
        type        = "MANAGED"
        managed = {
          domains = ["example.com", "www.example.com", "api.example.com"]
        }
      }
      admin-cert = {
        name        = "admin-cert"
        description = "Certificate for admin panel"
        project     = "test-project"
        type        = "MANAGED"
        managed = {
          domains = ["admin.example.com"]
        }
      }
    }
  }

  # Verify web-cert has multiple domains
  assert {
    condition     = length(google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["web-cert"].managed[0].domains) == 3
    error_message = "web-cert should have 3 domains"
  }

  # Verify all domains are present
  assert {
    condition = (
      contains(google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["web-cert"].managed[0].domains, "example.com") &&
      contains(google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["web-cert"].managed[0].domains, "www.example.com") &&
      contains(google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["web-cert"].managed[0].domains, "api.example.com")
    )
    error_message = "All configured domains should be present"
  }

  # Verify admin-cert has single domain
  assert {
    condition     = length(google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["admin-cert"].managed[0].domains) == 1
    error_message = "admin-cert should have 1 domain"
  }

  # Verify exactly 2 certificates are created
  assert {
    condition     = length(google_compute_managed_ssl_certificate.compute_managed_ssl_certificates) == 2
    error_message = "Should create exactly 2 certificates"
  }

  # Verify certificate names with prefix
  assert {
    condition = (
      google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["web-cert"].name == "staging-web-cert" &&
      google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["admin-cert"].name == "staging-admin-cert"
    )
    error_message = "Certificate names should be prefixed correctly"
  }

  # Verify both certificates are MANAGED type
  assert {
    condition = alltrue([
      for cert in google_compute_managed_ssl_certificate.compute_managed_ssl_certificates :
      cert.type == "MANAGED"
    ])
    error_message = "All certificates should be MANAGED type"
  }
}
