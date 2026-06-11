# ============================================================================
# Plan Test: logging-sink -> Pub/Sub (real-time fan-out) + exclusions
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

run "plan_pubsub" {
  command = plan

  variables {
    sinks = {
      stream = {
        name             = "logs-to-pubsub"
        destination_type = "pubsub"
        destination      = "log-stream"
        exclusions = {
          drop_healthchecks = {
            filter = "httpRequest.requestUrl=~\"/healthz\""
          }
        }
      }
    }
  }

  assert {
    condition     = google_logging_project_sink.sinks["stream"].destination == "pubsub.googleapis.com/projects/dummy-project/topics/log-stream"
    error_message = "Pub/Sub sink destination URI must be built from type + topic."
  }

  assert {
    condition     = google_pubsub_topic_iam_member.pubsub["stream"].role == "roles/pubsub.publisher"
    error_message = "Writer identity must be granted roles/pubsub.publisher on the topic."
  }

  assert {
    condition     = one(google_logging_project_sink.sinks["stream"].exclusions).name == "drop_healthchecks"
    error_message = "Exclusion must be wired with its logical key as the name."
  }
}
