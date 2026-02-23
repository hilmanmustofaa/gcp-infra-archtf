variables {
  project_id = "dummy-project"

  default_labels = {
    environment = "test"
  }

  join_separator  = "-"
  resource_prefix = "demo"

  storage_buckets = {
    main = {
      name     = "data"
      location = "ASIA-SOUTHEAST2"

      # optional fields omitted to exercise defaults
      labels                      = {}
      force_destroy               = false
      uniform_bucket_level_access = true
      public_access_prevention    = "inherited"
      storage_class               = "STANDARD"

      versioning = {
        enabled = false
      }

      autoclass               = null
      lifecycle_rules         = null
      retention_policy        = {}
      logging                 = {}
      website                 = null
      custom_placement_config = null
    }
  }

  objects = {}
}

run "basic_test" {
  command = plan

  assert {
    condition     = length(output.names) == 1
    error_message = "Expected exactly one bucket name in output.names."
  }

  assert {
    condition     = output.names["main"] == "demo-data"
    error_message = "Bucket name must be prefixed with resource_prefix and joined by join_separator."
  }

  assert {
    condition     = output.finops_labels["gcp_service"] == "storage.googleapis.com"
    error_message = "FinOps label gcp_service must be storage.googleapis.com."
  }

  assert {
    condition     = output.finops_labels["tf_module"] == "gcs-bucket"
    error_message = "FinOps label tf_module must be gcs-bucket."
  }
}
