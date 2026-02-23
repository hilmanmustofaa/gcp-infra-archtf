variables {
  project_id    = "example-project"
  location      = "asia-southeast2"
  repository_id = "ads-maven-lib"
  format        = "MAVEN"

  maven_allow_snapshot_overwrites = true
  maven_version_policy            = "SNAPSHOT"

  cleanup_policy_dry_run = true
  cleanup_policies = {
    delete-old = {
      action = "DELETE"
      condition = {
        tag_state             = "ANY"
        tag_prefixes          = null
        version_name_prefixes = null
        package_name_prefixes = null
        older_than            = "90d"
        newer_than            = null
      }
      most_recent_versions = {
        package_name_prefixes = null
        keep_count            = 5
      }
    }
  }

  labels = {
    env     = "prod"
    product = "ads"
  }
}

run "plan_maven_with_policies" {
  command = plan

  assert {
    condition     = google_artifact_registry_repository.this.format == "MAVEN"
    error_message = "Repository format must be MAVEN."
  }
}
