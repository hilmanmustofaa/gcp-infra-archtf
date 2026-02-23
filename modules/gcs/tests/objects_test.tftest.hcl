variables {
  project_id = "dummy-project"

  default_labels  = {}
  join_separator  = "-"
  resource_prefix = null

  storage_buckets = {
    main = {
      name     = "objects-bucket"
      location = "US"

      labels                      = {}
      force_destroy               = true
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

  objects = {
    test-object = {
      bucket              = "main" # key in storage_buckets.
      name                = "config.json"
      metadata            = null
      content             = "{}"
      source              = null
      cache_control       = null
      content_disposition = null
      content_encoding    = null
      content_language    = null
      content_type        = "application/json"
      storage_class       = null
      customer_encryption = null
    }
  }
}

run "objects_test" {
  command = plan

  assert {
    condition     = length(output.objects) == 1
    error_message = "Expected exactly one object in output.objects."
  }

  assert {
    condition     = output.objects["test-object"].name == "config.json"
    error_message = "Object name must be config.json."
  }

  assert {
    condition     = output.objects["test-object"].bucket == "objects-bucket"
    error_message = "Object bucket must equal the created bucket name."
  }
}
