variable "cdn_backend_buckets" {
  description = "A map of CDN backend bucket objects. Each backend bucket enables CDN for a Cloud Storage bucket. Note: google_compute_backend_bucket does not support labels."
  type = map(object({
    name                    = string
    description             = optional(string)
    bucket_name             = string
    project                 = optional(string)
    custom_response_headers = optional(list(string), [])
    cdn_policy = optional(object({
      cache_mode                   = optional(string)
      client_ttl                   = optional(number)
      default_ttl                  = optional(number)
      max_ttl                      = optional(number)
      negative_caching             = optional(bool)
      serve_while_stale            = optional(number)
      signed_url_cache_max_age_sec = optional(number)
      request_coalescing           = optional(bool)
      negative_caching_policy = optional(list(object({
        code = number
        ttl  = number
      })), [])
      cache_key_policy = optional(object({
        include_http_headers = optional(list(string))
      }))
      bypass_cache_on_request_headers = optional(list(object({
        header_name = string
      })), [])
    }))
  }))
  default = {}
}

variable "join_separator" {
  description = "The separator to use when joining the prefix and the name."
  type        = string
  default     = "-"
}

variable "resource_prefix" {
  description = "A prefix for the resource names."
  type        = string
  default     = null
}
