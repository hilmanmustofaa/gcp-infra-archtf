# ============================================================================
# Plan Test: IAP brand + OAuth client (count-guarded singleton)
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

run "plan_with_brand" {
  command = plan

  variables {
    create_brand = true
    brand = {
      support_email     = "iap-support@example.com"
      application_title = "Internal Apps"
    }
    create_client = true
    oauth_client = {
      display_name = "internal-apps-client"
    }
  }

  assert {
    condition     = google_iap_brand.brand[0].support_email == "iap-support@example.com"
    error_message = "Brand support_email must be wired."
  }

  assert {
    condition     = google_iap_brand.brand[0].application_title == "Internal Apps"
    error_message = "Brand application_title must be wired."
  }

  assert {
    condition     = google_iap_client.client[0].display_name == "internal-apps-client"
    error_message = "OAuth client display_name must be wired."
  }
}

run "plan_brand_disabled_by_default" {
  command = plan

  variables {
    tunnel_instance_bindings = {
      bastion = {
        zone     = "asia-southeast2-a"
        instance = "bastion-host"
        members  = ["group:sre@example.com"]
      }
    }
  }

  # No brand created when create_brand is false (default).
  assert {
    condition     = length(google_iap_brand.brand) == 0
    error_message = "Brand must not be created when create_brand is false."
  }

  assert {
    condition     = output.brand_name == null
    error_message = "brand_name output must be null when no brand is created."
  }
}
