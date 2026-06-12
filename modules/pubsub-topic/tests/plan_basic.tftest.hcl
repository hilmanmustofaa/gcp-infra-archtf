mock_provider "google" {}

variables {
  project_id      = "dummy-project"
  resource_prefix = "demo"
  default_labels = {
    env     = "test"
    project = "demo"
    owner   = "platform"
  }
}

run "plan_basic" {
  command = plan

  variables {
    topics = {
      events = {
        name = "events"
        iam_members = {
          publisher = {
            role   = "roles/pubsub.publisher"
            member = "serviceAccount:app@dummy-project.iam.gserviceaccount.com"
          }
        }
      }
    }
    subscriptions = {
      worker = {
        name                 = "events-worker"
        topic                = "events"
        ack_deadline_seconds = 30
        iam_members = {
          subscriber = {
            role   = "roles/pubsub.subscriber"
            member = "serviceAccount:worker@dummy-project.iam.gserviceaccount.com"
          }
        }
      }
    }
  }

  assert {
    condition     = google_pubsub_topic.topics["events"].name == "demo-events"
    error_message = "Topic name must be prefixed with resource_prefix."
  }

  assert {
    condition     = google_pubsub_topic.topics["events"].labels["tf_module"] == "pubsub-topic"
    error_message = "Topic must carry the tf_module FinOps label."
  }

  assert {
    condition     = google_pubsub_topic_iam_member.members["events/publisher"].role == "roles/pubsub.publisher"
    error_message = "Topic IAM member must be created with the configured role."
  }

  assert {
    condition     = google_pubsub_subscription.subscriptions["worker"].name == "demo-events-worker"
    error_message = "Subscription name must be prefixed."
  }

  assert {
    condition     = google_pubsub_subscription_iam_member.members["worker/subscriber"].role == "roles/pubsub.subscriber"
    error_message = "Subscription IAM member must be created with the configured role."
  }
}

run "plan_with_cmek_and_dead_letter" {
  command = plan

  variables {
    topics = {
      secure = {
        name         = "secure"
        kms_key_name = "projects/dummy-project/locations/asia-southeast2/keyRings/ps/cryptoKeys/ps-key"
      }
      dlq = {
        name = "secure-dlq"
      }
    }
    subscriptions = {
      sub = {
        name                  = "secure-sub"
        topic                 = "secure"
        push_endpoint         = "https://example.com/push"
        dead_letter_topic     = "projects/dummy-project/topics/demo-secure-dlq"
        max_delivery_attempts = 5
        expiration_ttl        = ""
      }
    }
  }

  assert {
    condition     = google_pubsub_topic.topics["secure"].kms_key_name == "projects/dummy-project/locations/asia-southeast2/keyRings/ps/cryptoKeys/ps-key"
    error_message = "CMEK key must be wired onto the topic."
  }

  assert {
    condition     = google_pubsub_subscription.subscriptions["sub"].push_config[0].push_endpoint == "https://example.com/push"
    error_message = "Push endpoint must be wired."
  }

  assert {
    condition     = google_pubsub_subscription.subscriptions["sub"].dead_letter_policy[0].max_delivery_attempts == 5
    error_message = "Dead-letter policy must be wired."
  }
}
