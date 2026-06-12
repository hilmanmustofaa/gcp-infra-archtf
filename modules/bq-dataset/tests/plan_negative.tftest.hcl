mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

# Missing FinOps label keys => fail.
run "missing_finops_labels" {
  command = plan

  variables {
    default_labels = { env = "test" } # missing project + owner
    datasets       = {}
  }

  expect_failures = [var.default_labels]
}

# Invalid dataset_id (BigQuery ids are underscore-only) => fail.
run "invalid_dataset_id" {
  command = plan

  variables {
    default_labels = { env = "test", project = "demo", owner = "platform" }
    datasets = {
      bad = { dataset_id = "has-dashes" }
    }
  }

  expect_failures = [var.datasets]
}
