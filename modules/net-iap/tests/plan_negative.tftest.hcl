# ============================================================================
# Plan Test: net-iap validation negatives
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

# create_brand without brand config => fail.
run "brand_without_config" {
  command = plan

  variables {
    create_brand = true
    brand        = null
  }

  expect_failures = [var.brand]
}

# create_client without create_brand => fail.
run "client_without_brand" {
  command = plan

  variables {
    create_brand  = false
    create_client = true
    oauth_client  = { display_name = "x" }
  }

  expect_failures = [var.create_client]
}

# create_client without oauth_client config => fail.
run "client_without_config" {
  command = plan

  variables {
    create_brand = true
    brand = {
      support_email     = "x@example.com"
      application_title = "X"
    }
    create_client = true
    oauth_client  = null
  }

  expect_failures = [var.oauth_client]
}
