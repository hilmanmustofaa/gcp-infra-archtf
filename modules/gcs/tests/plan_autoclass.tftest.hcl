mock_provider "google" {}

# ============================================================================
# Plan Test: GCS Autoclass + conflict validation
# ============================================================================
# Verifies:
#   - autoclass object (enabled + terminal_storage_class) is wired through
#   - autoclass + lifecycle_rules on the same bucket is rejected (GCP constraint)
#   - terminal_storage_class is constrained to NEARLINE | ARCHIVE
# ============================================================================

variables {
  project_id      = "dummy-project"
  resource_prefix = "demo"
  join_separator  = "-"
  default_labels  = {}
  objects         = {}
}

run "plan_autoclass_enabled" {
  command = plan

  variables {
    storage_buckets = {
      archive = {
        name     = "cold-data"
        location = "ASIA-SOUTHEAST2"
        autoclass = {
          enabled                = true
          terminal_storage_class = "ARCHIVE"
        }
      }
    }
  }

  assert {
    condition     = output.buckets["archive"].autoclass[0].enabled == true
    error_message = "Autoclass must be enabled on the bucket."
  }

  assert {
    condition     = output.buckets["archive"].autoclass[0].terminal_storage_class == "ARCHIVE"
    error_message = "Autoclass terminal_storage_class must be ARCHIVE."
  }
}

# Negative: autoclass + lifecycle_rules together must fail validation.
run "autoclass_lifecycle_conflict" {
  command = plan

  variables {
    storage_buckets = {
      bad = {
        name     = "conflict"
        location = "ASIA-SOUTHEAST2"
        autoclass = {
          enabled = true
        }
        lifecycle_rules = {
          to_nearline = {
            action = {
              type          = "SetStorageClass"
              storage_class = "NEARLINE"
            }
            condition = {
              age = 30
            }
          }
        }
      }
    }
  }

  expect_failures = [var.storage_buckets]
}

# Negative: invalid terminal_storage_class must fail validation.
run "autoclass_bad_terminal_class" {
  command = plan

  variables {
    storage_buckets = {
      bad = {
        name     = "badclass"
        location = "ASIA-SOUTHEAST2"
        autoclass = {
          enabled                = true
          terminal_storage_class = "COLDLINE"
        }
      }
    }
  }

  expect_failures = [var.storage_buckets]
}