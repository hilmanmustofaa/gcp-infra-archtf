module "cdn" {
  source = "../.."

  resource_prefix = "multi"
  join_separator  = "-"

  cdn_backend_buckets = {
    # Frontend static assets
    frontend-assets = {
      name        = "frontend-assets"
      description = "CDN for frontend static assets (JS, CSS, images)"
      bucket_name = "frontend-assets-bucket"
      project     = "my-project-id"

      custom_response_headers = [
        "X-Cache-Status: {cdn_cache_status}",
        "X-Content-Type-Options: nosniff"
      ]

      cdn_policy = {
        cache_mode  = "CACHE_ALL_STATIC"
        default_ttl = 86400  # 24 hours for static assets
        max_ttl     = 604800 # 7 days
        client_ttl  = 3600

        negative_caching = true
        negative_caching_policy = [
          {
            code = 404
            ttl  = 300
          }
        ]
      }
    }

    # API response caching
    api-cache = {
      name        = "api-cache"
      description = "CDN for API response caching"
      bucket_name = "api-cache-bucket"
      project     = "my-project-id"

      custom_response_headers = [
        "X-Cache-Status: {cdn_cache_status}",
        "Access-Control-Allow-Origin: *"
      ]

      cdn_policy = {
        cache_mode  = "CACHE_ALL_STATIC"
        default_ttl = 300  # 5 minutes for API responses
        max_ttl     = 3600 # 1 hour max
        client_ttl  = 60

        request_coalescing = true

        cache_key_policy = {
          include_http_headers = ["X-API-Version"]
        }

        bypass_cache_on_request_headers = [
          {
            header_name = "X-No-Cache"
          }
        ]
      }
    }

    # Media files (images, videos)
    media-files = {
      name        = "media-files"
      description = "CDN for media files with long cache times"
      bucket_name = "media-files-bucket"
      project     = "my-project-id"

      custom_response_headers = [
        "X-Cache-Status: {cdn_cache_status}",
        "Cache-Control: public, immutable, max-age=31536000"
      ]

      cdn_policy = {
        cache_mode  = "CACHE_ALL_STATIC"
        default_ttl = 2592000  # 30 days
        max_ttl     = 31536000 # 1 year
        client_ttl  = 86400

        serve_while_stale  = 86400
        request_coalescing = true
      }
    }
  }
}

# Outputs for all backend buckets
output "all_backend_bucket_ids" {
  description = "Map of all backend bucket IDs"
  value       = module.cdn.backend_bucket_ids
}

output "all_backend_bucket_names" {
  description = "Map of all backend bucket names"
  value       = module.cdn.backend_bucket_names
}

output "frontend_assets_self_link" {
  description = "Self link for frontend assets backend bucket"
  value       = module.cdn.backend_bucket_self_links["frontend-assets"]
}

output "api_cache_self_link" {
  description = "Self link for API cache backend bucket"
  value       = module.cdn.backend_bucket_self_links["api-cache"]
}

output "media_files_self_link" {
  description = "Self link for media files backend bucket"
  value       = module.cdn.backend_bucket_self_links["media-files"]
}
