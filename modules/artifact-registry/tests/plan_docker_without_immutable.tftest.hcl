variables {
  project_id    = "example-project"
  location      = "asia-southeast2"
  repository_id = "generic-docker-repo"
  format        = "DOCKER"

  docker_immutable_tags  = null
  cleanup_policy_dry_run = false

  labels = {
    env     = "uat"
    product = "generic"
  }
}

run "plan_docker_without_immutable" {
  command = plan

  assert {
    condition     = google_artifact_registry_repository.this.format == "DOCKER"
    error_message = "Repository format must be DOCKER."
  }
}
