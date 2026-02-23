run "plan_basic_policy" {
  command = plan

  variables {
    project_id = "test-project"
    name       = "test-policy"


  }

  # Verify Response Policy
  assert {
    condition     = google_dns_response_policy.default[0].response_policy_name == "test-policy"
    error_message = "Policy name incorrect"
  }


}
