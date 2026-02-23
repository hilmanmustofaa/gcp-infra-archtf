variables {
  project_id    = "demo-project"
  location      = "asia-southeast2"
  repository_id = "demo-repo"
  format        = "DOCKER"

  docker_immutable_tags  = true
  cleanup_policy_dry_run = true
  cleanup_policies = {
    delete-untagged = {
      action = "DELETE"
      condition = {
        tag_state             = "UNTAGGED"
        tag_prefixes          = null
        version_name_prefixes = null
        package_name_prefixes = null
        older_than            = null
        newer_than            = null
      }
      most_recent_versions = null
    }
  }

  labels = {
    env         = "dev"
    product     = "ads"
    cost_center = "cc-1234"
  }
}

run "basic_test" {
  command = plan

  assert {
    condition     = google_artifact_registry_repository.this.format == "DOCKER"
    error_message = "Repository format should be DOCKER."
  }
}
