run "plan_basic_cdn" {
  command = plan

  variables {
    resource_prefix = "dev"
    join_separator  = "-"

    cdn_backend_buckets = {
      static-assets = {
        name        = "static-assets"
        description = "Basic CDN backend bucket for static assets"
        bucket_name = "my-static-assets-bucket"
        project     = "test-project"
      }
    }
  }

  # Verify backend bucket is created with correct name
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["static-assets"].name == "dev-static-assets"
    error_message = "Backend bucket name should be prefixed correctly"
  }

  # Verify CDN is enabled
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["static-assets"].enable_cdn == true
    error_message = "CDN should be enabled for backend bucket"
  }

  # Verify bucket name is correct
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["static-assets"].bucket_name == "my-static-assets-bucket"
    error_message = "Bucket name should match the configured value"
  }

  # Verify exactly one backend bucket is created
  assert {
    condition     = length(google_compute_backend_bucket.cdn_backend_buckets) == 1
    error_message = "Should create exactly one backend bucket"
  }

  # Verify description is set
  assert {
    condition     = google_compute_backend_bucket.cdn_backend_buckets["static-assets"].description == "Basic CDN backend bucket for static assets"
    error_message = "Description should match configured value"
  }
}
