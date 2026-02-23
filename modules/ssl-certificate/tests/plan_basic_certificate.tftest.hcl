run "plan_basic_certificate" {
  command = plan

  variables {
    resource_prefix = "prod"
    join_separator  = "-"

    compute_managed_ssl_certificates = {
      example-cert = {
        name        = "example-cert"
        description = "Basic managed SSL certificate"
        project     = "test-project"
        type        = "MANAGED"
        managed = {
          domains = ["example.com"]
        }
      }
    }
  }

  # Verify certificate is created with correct name
  assert {
    condition     = google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["example-cert"].name == "prod-example-cert"
    error_message = "Certificate name should be prefixed correctly"
  }

  # Verify certificate type
  assert {
    condition     = google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["example-cert"].type == "MANAGED"
    error_message = "Certificate type should be MANAGED"
  }

  # Verify domains configuration
  assert {
    condition     = length(google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["example-cert"].managed[0].domains) == 1
    error_message = "Should have exactly 1 domain"
  }

  # Verify domain value
  assert {
    condition     = google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["example-cert"].managed[0].domains[0] == "example.com"
    error_message = "Domain should be example.com"
  }

  # Verify description
  assert {
    condition     = google_compute_managed_ssl_certificate.compute_managed_ssl_certificates["example-cert"].description == "Basic managed SSL certificate"
    error_message = "Description should match configured value"
  }

  # Verify exactly one certificate is created
  assert {
    condition     = length(google_compute_managed_ssl_certificate.compute_managed_ssl_certificates) == 1
    error_message = "Should create exactly one certificate"
  }
}
