module "cdn" {
  source = "../.."

  resource_prefix = "prod"

  cdn_backend_buckets = {
    advanced-cdn = {
      name        = "advanced-cdn"
      description = "Advanced CDN with comprehensive policy configuration"
      bucket_name = "my-advanced-cdn-bucket"
      project     = "my-project-id"

      # Custom response headers for security and debugging
      custom_response_headers = [
        "X-Cache-Status: {cdn_cache_status}",
        "X-Content-Type-Options: nosniff",
        "X-Frame-Options: SAMEORIGIN",
        "Strict-Transport-Security: max-age=31536000; includeSubDomains",
        "Cache-Control: public, max-age=3600"
      ]

      cdn_policy = {
        # Cache all static content
        cache_mode = "CACHE_ALL_STATIC"

        # TTL configuration
        client_ttl  = 3600  # 1 hour - how long clients should cache
        default_ttl = 7200  # 2 hours - default cache time if no Cache-Control header
        max_ttl     = 86400 # 24 hours - maximum cache time regardless of headers

        # Serve stale content while revalidating
        serve_while_stale = 3600 # 1 hour

        # Enable negative caching for error responses
        negative_caching = true
        negative_caching_policy = [
          {
            code = 404
            ttl  = 300 # Cache 404s for 5 minutes
          },
          {
            code = 403
            ttl  = 120 # Cache 403s for 2 minutes
          },
          {
            code = 410
            ttl  = 600 # Cache 410s for 10 minutes
          }
        ]

        # Signed URL configuration
        signed_url_cache_max_age_sec = 7200 # 2 hours

        # Request coalescing to reduce origin load
        request_coalescing = true

        # Cache key policy - vary cache based on specific headers
        cache_key_policy = {
          include_http_headers = [
            "X-User-Country",
            "Accept-Language"
          ]
        }

        # Bypass cache for specific headers (e.g., for debugging)
        bypass_cache_on_request_headers = [
          {
            header_name = "X-Bypass-Cache"
          },
          {
            header_name = "Pragma"
          }
        ]
      }
    }
  }
}

# Outputs
output "backend_bucket_id" {
  description = "The ID of the advanced CDN backend bucket"
  value       = module.cdn.backend_bucket_ids["advanced-cdn"]
}

output "backend_bucket_self_link" {
  description = "The self link of the advanced CDN backend bucket"
  value       = module.cdn.backend_bucket_self_links["advanced-cdn"]
}

output "backend_bucket_name" {
  description = "The name of the advanced CDN backend bucket"
  value       = module.cdn.backend_bucket_names["advanced-cdn"]
}
