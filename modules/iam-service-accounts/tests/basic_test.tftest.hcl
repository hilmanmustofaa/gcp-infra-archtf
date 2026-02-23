variables {
  project_id             = "dummy-project"
  account_id             = "test-sa-basic"
  service_account_create = true

  description  = "Basic test service account."
  disabled     = false
  display_name = "Basic Test SA."
  generate_key = false
  prefix       = ""

  iam_bindings                = {}
  iam_bindings_additive       = {}
  project_iam_bindings        = {}
  storage_bucket_iam_bindings = {}

  labels = {
    environment = "test"
  }
}

run "basic_test" {
  command = plan

  assert {
    condition     = output.name == var.account_id
    error_message = "Service account name output must equal account_id."
  }

  assert {
    condition     = output.email == "${var.account_id}@${var.project_id}.iam.gserviceaccount.com"
    error_message = "Service account email must match account_id@project_id.iam.gserviceaccount.com."
  }

  assert {
    condition     = output.finops_labels["gcp_service"] == "iam.googleapis.com"
    error_message = "FinOps label gcp_service must be iam.googleapis.com."
  }

  assert {
    condition     = output.finops_labels["tf_module"] == "iam-service-account"
    error_message = "FinOps label tf_module must be iam-service-account."
  }
}
