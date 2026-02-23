module "cdn" {
  source = "../.."

  resource_prefix = "prod"
  join_separator  = "-"

  cdn_backend_buckets = {
    static-assets = {
      name        = "static-assets"
      description = "CDN backend bucket for static website assets"
      bucket_name = "my-static-assets-bucket" # Must be an existing GCS bucket
      project     = "my-project-id"

      # Custom response headers for security and caching
      custom_response_headers = [
        "X-Cache-Status: {cdn_cache_status}",
        "X-Content-Type-Options: nosniff",
        "X-Frame-Options: DENY"
      ]

      # Basic CDN policy configuration
      cdn_policy = {
        cache_mode  = "CACHE_ALL_STATIC"
        default_ttl = 3600  # 1 hour
        max_ttl     = 86400 # 24 hours
        client_ttl  = 1800  # 30 minutes

        # Enable negative caching for error responses
        negative_caching = true
        negative_caching_policy = [
          {
            code = 404
            ttl  = 300 # Cache 404s for 5 minutes
          }
        ]
      }
    }
  }
}

# Outputs for reference
output "backend_bucket_id" {
  description = "The ID of the created backend bucket"
  value       = module.cdn.backend_bucket_ids["static-assets"]
}

output "backend_bucket_self_link" {
  description = "The self link of the created backend bucket"
  value       = module.cdn.backend_bucket_self_links["static-assets"]
}
