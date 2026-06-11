# ============================================================================
# Plan Test: IAP web backend service IAM (protect Cloud Run / GKE behind a LB)
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

run "plan_web_backend" {
  command = plan

  variables {
    web_backend_bindings = {
      app = {
        web_backend_service = "app-backend"
        members             = ["domain:example.com"]
      }
    }
  }

  assert {
    condition     = google_iap_web_backend_service_iam_binding.web_backend_bindings["app"].role == "roles/iap.httpsResourceAccessor"
    error_message = "Web backend binding must default to roles/iap.httpsResourceAccessor."
  }

  assert {
    condition     = google_iap_web_backend_service_iam_binding.web_backend_bindings["app"].web_backend_service == "app-backend"
    error_message = "Web backend binding must target the configured backend service."
  }
}
