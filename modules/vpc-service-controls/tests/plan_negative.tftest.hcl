mock_provider "google" {}

variables {
  access_policy_id = "accessPolicies/123456789"
}

# Missing FinOps label keys => fail.
run "missing_finops_labels" {
  command = plan

  variables {
    default_labels = { env = "test" } # missing project + owner
  }

  expect_failures = [var.default_labels]
}

# Access level key with a dash is invalid (ACM ids are underscore-only).
run "invalid_access_level_key" {
  command = plan

  variables {
    default_labels = { env = "test", project = "demo", owner = "platform" }
    access_levels = {
      "corp-net" = {
        title      = "bad"
        conditions = [{ regions = ["ID"] }]
      }
    }
  }

  expect_failures = [var.access_levels]
}

# Perimeter key with a dash is invalid.
run "invalid_perimeter_key" {
  command = plan

  variables {
    default_labels = { env = "test", project = "demo", owner = "platform" }
    service_perimeters = {
      "data-perim" = {
        title = "bad"
      }
    }
  }

  expect_failures = [var.service_perimeters]
}
