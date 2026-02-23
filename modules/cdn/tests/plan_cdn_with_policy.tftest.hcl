run "plan_cdn_with_policy" {
  command = plan

  variables {
    resource_prefix = "prod"

    cdn_backend_buckets = {
      advanced-cdn = {
        name        = "advanced-cdn"
        description = "Advanced CDN with full policy configuration"
        bucket_name = "my-advanced-cdn-bucket"
        project     = "test-project"
        custom_response_headers = [
          "X-Cache-Status: {cdn_cache_status}",
          "X-Content-Type-Options: nosniff"
        ]
        cdn_policy = {
          cache_mode                   = "CACHE_ALL_STATIC"
          client_ttl                   = 3600
          default_ttl                  = 7200
          max_ttl                      = 86400
          negative_caching             = true
          serve_while_stale            = 3600
          signed_url_cache_max_age_sec = 7200
          request_coalescing           = true
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
          cache_key_policy = {
            include_http_headers = ["X-Custom-Header", "X-User-ID"]
          }
          bypass_cache_on_request_headers = [
            {
              header_name = "X-Bypass-Cache"
            }
          ]
        }
      }
    }
  }

  # Verify CDN policy cache_mode
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].cache_mode == "CACHE_ALL_STATIC"
    error_message = "Cache mode should be CACHE_ALL_STATIC"
  }

  # Verify TTL settings
  assert {
    condition = (
      google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].client_ttl == 3600 &&
      google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].default_ttl == 7200 &&
      google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].max_ttl == 86400
    )
    error_message = "TTL settings should match configured values"
  }

  # Verify negative caching is enabled
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].negative_caching == true
    error_message = "Negative caching should be enabled"
  }

  # Verify negative caching policy count
  assert {
    condition     = length(google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].negative_caching_policy) == 2
    error_message = "Should have 2 negative caching policies"
  }

  # Verify cache key policy includes HTTP headers
  assert {
    condition     = length(google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].cache_key_policy[0].include_http_headers) == 2
    error_message = "Cache key policy should include 2 HTTP headers"
  }

  # Verify custom response headers
  assert {
    condition     = length(google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].custom_response_headers) == 2
    error_message = "Should have 2 custom response headers"
  }

  # Verify request coalescing is enabled
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].request_coalescing == true
    error_message = "Request coalescing should be enabled"
  }

  # Verify bypass cache headers
  assert {
    condition     = length(google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].bypass_cache_on_request_headers) == 1
    error_message = "Should have 1 bypass cache header"
  }

  # Verify serve_while_stale
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].serve_while_stale == 3600
    error_message = "Serve while stale should be 3600 seconds"
  }

  # Verify signed URL cache max age
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["advanced-cdn"].cdn_policy[0].signed_url_cache_max_age_sec == 7200
    error_message = "Signed URL cache max age should be 7200 seconds"
  }
}
