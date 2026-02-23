resource "google_compute_backend_bucket" "cdn_backend_buckets" {
  provider = google-beta
  for_each = var.cdn_backend_buckets

  name                    = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  description             = each.value.description
  bucket_name             = each.value.bucket_name
  enable_cdn              = true
  project                 = each.value.project
  custom_response_headers = each.value.custom_response_headers


  dynamic "cdn_policy" {
    for_each = each.value.cdn_policy != null ? [each.value.cdn_policy] : []
    content {
      cache_mode                   = cdn_policy.value.cache_mode
      client_ttl                   = cdn_policy.value.client_ttl
      default_ttl                  = cdn_policy.value.default_ttl
      max_ttl                      = cdn_policy.value.max_ttl
      negative_caching             = cdn_policy.value.negative_caching
      serve_while_stale            = cdn_policy.value.serve_while_stale
      signed_url_cache_max_age_sec = cdn_policy.value.signed_url_cache_max_age_sec
      request_coalescing           = cdn_policy.value.request_coalescing

      dynamic "negative_caching_policy" {
        for_each = cdn_policy.value.negative_caching_policy != null ? cdn_policy.value.negative_caching_policy : []
        content {
          code = negative_caching_policy.value.code
          ttl  = negative_caching_policy.value.ttl
        }
      }

      dynamic "cache_key_policy" {
        for_each = cdn_policy.value.cache_key_policy != null ? [cdn_policy.value.cache_key_policy] : []
        content {
          include_http_headers = cache_key_policy.value.include_http_headers
        }
      }

      dynamic "bypass_cache_on_request_headers" {
        for_each = cdn_policy.value.bypass_cache_on_request_headers != null ? cdn_policy.value.bypass_cache_on_request_headers : []
        content {
          header_name = bypass_cache_on_request_headers.value.header_name
        }
      }
    }
  }
}
