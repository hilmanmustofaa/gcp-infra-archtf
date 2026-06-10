# ============================================================================
# Plan Test: logging-sink validation negatives
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

# Invalid destination_type => fail.
run "bad_destination_type" {
  command = plan

  variables {
    sinks = {
      bad = {
        name             = "x"
        destination_type = "spanner"
        destination      = "whatever"
      }
    }
  }

  expect_failures = [var.sinks]
}
