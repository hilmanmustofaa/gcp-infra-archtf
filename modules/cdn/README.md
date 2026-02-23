# CDN Module

<!-- BEGIN TOC -->

- [Description](#description)
- [Features](#features)
- [Labeling Strategy](#labeling-strategy)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
- [Basic CDN Configuration](#basic-cdn-configuration)
- [Advanced CDN with Full Policy](#advanced-cdn-with-full-policy)
- [Multiple Backend Buckets](#multiple-backend-buckets)
- [Best Practices](#best-practices)
<!-- END TOC -->

# Description

This module manages Google Cloud CDN configurations through `google_compute_backend_bucket` resources. It enables and configures CDN policies for static content served from Cloud Storage buckets with comprehensive caching controls and custom headers.

# Features

- **Backend Buckets**: Create and configure backend buckets with CDN enabled
- **Comprehensive CDN Policies**: Configure cache modes, TTLs (client, default, max), negative caching, serve-while-stale, and request coalescing
- **Cache Key Policy**: Customize cache keys based on HTTP headers for fine-grained cache control
- **Custom Response Headers**: Add security and caching headers to CDN responses
- **Bypass Cache Headers**: Configure headers that bypass the CDN cache for debugging or dynamic content
- **Signed URLs**: Configure signed URL cache duration for secure content delivery
- **Flexible Naming**: Support `resource_prefix` and `join_separator` for consistent naming conventions

# Labeling Strategy

> **Note**: The `google_compute_backend_bucket` resource does not support labels directly. For cost tracking and asset management, apply labels to the underlying Cloud Storage buckets instead.

To implement FinOps labels for CDN resources:

1. Apply labels to the Cloud Storage buckets that serve as CDN origins
2. Use consistent naming conventions via `resource_prefix` for resource organization
3. Leverage GCP's built-in CDN metrics and logging for cost attribution
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [cdn_backend_buckets](variables.tf#L1) | A map of CDN backend bucket objects. Each backend bucket enables CDN for a Cloud Storage bucket. Note: google_compute_backend_bucket does not support labels. | <code title="map&#40;object&#40;&#123;&#10;  name                    &#61; string&#10;  description             &#61; optional&#40;string&#41;&#10;  bucket_name             &#61; string&#10;  project                 &#61; optional&#40;string&#41;&#10;  custom_response_headers &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  cdn_policy &#61; optional&#40;object&#40;&#123;&#10;    cache_mode                   &#61; optional&#40;string&#41;&#10;    client_ttl                   &#61; optional&#40;number&#41;&#10;    default_ttl                  &#61; optional&#40;number&#41;&#10;    max_ttl                      &#61; optional&#40;number&#41;&#10;    negative_caching             &#61; optional&#40;bool&#41;&#10;    serve_while_stale            &#61; optional&#40;number&#41;&#10;    signed_url_cache_max_age_sec &#61; optional&#40;number&#41;&#10;    request_coalescing           &#61; optional&#40;bool&#41;&#10;    negative_caching_policy &#61; optional&#40;list&#40;object&#40;&#123;&#10;      code &#61; number&#10;      ttl  &#61; number&#10;    &#125;&#41;&#41;, &#91;&#93;&#41;&#10;    cache_key_policy &#61; optional&#40;object&#40;&#123;&#10;      include_http_headers &#61; optional&#40;list&#40;string&#41;&#41;&#10;    &#125;&#41;&#41;&#10;    bypass_cache_on_request_headers &#61; optional&#40;list&#40;object&#40;&#123;&#10;      header_name &#61; string&#10;    &#125;&#41;&#41;, &#91;&#93;&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L33) | The separator to use when joining the prefix and the name. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L39) | A prefix for the resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [backend_bucket_ids](outputs.tf#L1) | Map of backend bucket IDs. |  |
| [backend_bucket_names](outputs.tf#L8) | Map of backend bucket names. |  |
| [backend_bucket_self_links](outputs.tf#L15) | Map of backend bucket self links. |  |
| [cdn_backend_buckets](outputs.tf#L22) | The created CDN backend buckets. |  |
<!-- END TFDOC -->
# Example Usage

## Basic CDN Configuration

```hcl
module "cdn" {
  source = "./modules/cdn"

  resource_prefix = "prod"

  cdn_backend_buckets = {
    static-assets = {
      name        = "static-assets"
      description = "CDN for static website assets"
      bucket_name = "my-static-assets-bucket"

      custom_response_headers = [
        "X-Cache-Status: {cdn_cache_status}",
        "X-Content-Type-Options: nosniff"
      ]

      cdn_policy = {
        cache_mode  = "CACHE_ALL_STATIC"
        default_ttl = 3600
        max_ttl     = 86400

        negative_caching = true
        negative_caching_policy = [
          {
            code = 404
            ttl  = 300
          }
        ]
      }
    }
  }
}
```

## Advanced CDN with Full Policy

```hcl
module "cdn" {
  source = "./modules/cdn"

  resource_prefix = "prod"

  cdn_backend_buckets = {
    advanced-cdn = {
      name        = "advanced-cdn"
      description = "Advanced CDN with comprehensive policy"
      bucket_name = "my-advanced-cdn-bucket"

      custom_response_headers = [
        "X-Cache-Status: {cdn_cache_status}",
        "Strict-Transport-Security: max-age=31536000",
        "X-Content-Type-Options: nosniff"
      ]

      cdn_policy = {
        cache_mode                   = "CACHE_ALL_STATIC"
        client_ttl                   = 3600
        default_ttl                  = 7200
        max_ttl                      = 86400
        serve_while_stale            = 3600
        signed_url_cache_max_age_sec = 7200
        request_coalescing           = true
        negative_caching             = true

        negative_caching_policy = [
          {
            code = 404
            ttl  = 300
          },
          {
            code = 403
            ttl  = 120
          }
        ]

        # Vary cache based on specific headers
        cache_key_policy = {
          include_http_headers = ["X-User-Country", "Accept-Language"]
        }

        # Bypass cache for debugging
        bypass_cache_on_request_headers = [
          {
            header_name = "X-Bypass-Cache"
          }
        ]
      }
    }
  }
}
```

## Multiple Backend Buckets

```hcl
module "cdn" {
  source = "./modules/cdn"

  resource_prefix = "multi"

  cdn_backend_buckets = {
    # Static assets with long cache
    frontend-assets = {
      name        = "frontend-assets"
      description = "CDN for frontend static assets"
      bucket_name = "frontend-assets-bucket"

      cdn_policy = {
        cache_mode  = "CACHE_ALL_STATIC"
        default_ttl = 86400  # 24 hours
        max_ttl     = 604800 # 7 days
      }
    }

    # API cache with short TTL
    api-cache = {
      name        = "api-cache"
      description = "CDN for API responses"
      bucket_name = "api-cache-bucket"

      cdn_policy = {
        cache_mode         = "CACHE_ALL_STATIC"
        default_ttl        = 300  # 5 minutes
        request_coalescing = true

        cache_key_policy = {
          include_http_headers = ["X-API-Version"]
        }
      }
    }
  }
}
```

# Best Practices

1. **TTL Configuration**:

   - Set `client_ttl` ≤ `default_ttl` ≤ `max_ttl`
   - Use longer TTLs for static assets (images, CSS, JS)
   - Use shorter TTLs for frequently updated content

2. **Negative Caching**:

   - Enable negative caching to reduce origin load for error responses
   - Configure appropriate TTLs for different error codes (404, 403, etc.)

3. **Custom Response Headers**:

   - Add security headers (X-Content-Type-Options, X-Frame-Options, etc.)
   - Include cache status headers for debugging
   - Use HSTS headers for HTTPS enforcement

4. **Cache Key Policy**:

   - Only include headers that truly affect content variation
   - Minimize the number of headers to improve cache hit ratio
   - Common headers: Accept-Language, X-User-Country, X-API-Version

5. **Request Coalescing**:

   - Enable for high-traffic sites to reduce origin load
   - Particularly useful for cache misses on popular content

6. **Cost Management**:

   - Apply labels to underlying Cloud Storage buckets for cost tracking
   - Use consistent naming with `resource_prefix` for resource organization
   - Monitor CDN cache hit ratios to optimize costs
   - Review egress costs and configure appropriate TTLs

7. **Bypass Cache Headers**:

   - Use for debugging and testing
   - Document which headers bypass cache
   - Restrict access to bypass headers in production

8. **Bucket Configuration**:
   - Ensure Cloud Storage buckets have appropriate lifecycle policies
   - Configure CORS settings on buckets if serving cross-origin content
   - Apply labels to buckets for FinOps tracking
