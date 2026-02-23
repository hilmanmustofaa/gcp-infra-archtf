run "plan_invalid_repository_id" {
  command = plan

  variables {
    project_id    = "dummy-project"
    location      = "asia-southeast2"
    format        = "DOCKER"
    mode          = "STANDARD_REPOSITORY"
    repository_id = "INVALID_UPPERCASE" # sengaja invalid (regex fail).
  }

  # Kita expect validation error dari var.repository_id.
  expect_failures = [
    var.repository_id,
  ]
}
