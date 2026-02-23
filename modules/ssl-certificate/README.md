# SSL Certificate Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Features](#features)
- [Important Notes](#important-notes)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
- [Basic Single Domain Certificate](#basic-single-domain-certificate)
- [Multi-Domain Certificate](#multi-domain-certificate)
- [Wildcard Certificate](#wildcard-certificate)
- [Best Practices](#best-practices)
<!-- END TOC -->

# Description

This module manages Google Cloud Managed SSL Certificates for use with Google Cloud Load Balancers. Google automatically provisions and renews these certificates.

# Features

- **Managed SSL Certificates**: Create and manage Google-managed SSL certificates that are automatically provisioned and renewed
- **Multi-Domain Support**: Single certificate can cover multiple domains (up to 100 domains per certificate)
- **Wildcard Certificates**: Support for wildcard domains (\*.example.com)
- **Automatic Renewal**: Google automatically renews certificates before expiration
- **Flexible Naming**: Support `resource_prefix` and `join_separator` for consistent naming conventions

# Important Notes

> **Note**: The `google_compute_managed_ssl_certificate` resource does not support labels.

**Certificate Provisioning:**

- Provisioning can take 10-60 minutes after creation
- Domains must be verified and pointing to the load balancer
- Certificate status can be checked in GCP Console

**Domain Requirements:**

- Domains must be publicly accessible
- DNS must point to the load balancer IP
- Wildcard certificates (\*.example.com) do NOT cover the apex domain (example.com)
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_managed_ssl_certificates](variables.tf#L1) | A map of managed SSL certificate objects. Note: google_compute_managed_ssl_certificate does not support labels. | <code title="map&#40;object&#40;&#123;&#10;  name        &#61; string&#10;  description &#61; optional&#40;string&#41;&#10;  project     &#61; optional&#40;string&#41;&#10;  type        &#61; optional&#40;string, &#34;MANAGED&#34;&#41;&#10;  managed &#61; object&#40;&#123;&#10;    domains &#61; list&#40;string&#41;&#10;  &#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L15) | The separator to use when joining the prefix and the name. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L21) | A prefix for the resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [certificate_ids](outputs.tf#L1) | Map of certificate IDs. |  |
| [certificate_names](outputs.tf#L8) | Map of certificate names. |  |
| [certificate_self_links](outputs.tf#L15) | Map of certificate self links. |  |
| [managed_ssl_certificates](outputs.tf#L22) | The created managed SSL certificates. |  |
<!-- END TFDOC -->
# Example Usage

## Basic Single Domain Certificate

```hcl
module "ssl_certificate" {
  source = "./modules/ssl-certificate"

  resource_prefix = "prod"

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

output "certificate_id" {
  value = module.ssl_certificate.certificate_ids["example"]
}
```

## Multi-Domain Certificate

A single certificate can cover multiple domains (up to 100):

```hcl
module "ssl_certificate" {
  source = "./modules/ssl-certificate"

  resource_prefix = "prod"

  compute_managed_ssl_certificates = {
    web-cert = {
      name        = "web-cert"
      description = "Certificate for web application"
      project     = "my-project-id"
      type        = "MANAGED"
      managed = {
        domains = [
          "example.com",
          "www.example.com",
          "api.example.com",
          "admin.example.com"
        ]
      }
    }
  }
}
```

## Wildcard Certificate

Wildcard certificates cover all subdomains but NOT the apex domain:

```hcl
module "ssl_certificate" {
  source = "./modules/ssl-certificate"

  resource_prefix = "prod"

  compute_managed_ssl_certificates = {
    # Wildcard only - covers *.example.com but NOT example.com
    wildcard-cert = {
      name        = "wildcard-cert"
      description = "Wildcard certificate for all subdomains"
      project     = "my-project-id"
      type        = "MANAGED"
      managed = {
        domains = ["*.example.com"]
      }
    }

    # Apex + Wildcard - covers both example.com and *.example.com
    complete-cert = {
      name        = "complete-cert"
      description = "Certificate for apex and all subdomains"
      project     = "my-project-id"
      type        = "MANAGED"
      managed = {
        domains = [
          "example.com",
          "*.example.com"
        ]
      }
    }
  }
}
```

# Best Practices

1. **Domain Verification**:

   - Ensure DNS is properly configured before creating certificates
   - Point domains to the load balancer IP address
   - Allow 10-60 minutes for certificate provisioning

2. **Multi-Domain Certificates**:

   - Group related domains in a single certificate (up to 100 domains)
   - Consider separate certificates for different environments (prod, staging)
   - Use descriptive names to identify certificate purpose

3. **Wildcard Certificates**:

   - Remember: `*.example.com` does NOT cover `example.com`
   - Include both apex and wildcard if you need complete coverage
   - Wildcard certificates are useful for dynamic subdomains

4. **Certificate Management**:

   - Google automatically renews certificates before expiration
   - Monitor certificate status in GCP Console
   - Certificates are tied to the load balancer - ensure load balancer is properly configured

5. **Naming Conventions**:

   - Use `resource_prefix` for environment separation (prod, staging, dev)
   - Use descriptive certificate names that indicate their purpose
   - Keep names short and meaningful

6. **Security**:

   - Use HTTPS-only load balancer configurations
   - Enable HTTP to HTTPS redirects
   - Consider using security policies with your load balancer

7. **Limitations**:
   - Maximum 100 domains per certificate
   - Certificates cannot be used with self-signed or imported certificates
   - No support for labels (use naming conventions for organization)
   - Provisioning time can vary (10-60 minutes)
