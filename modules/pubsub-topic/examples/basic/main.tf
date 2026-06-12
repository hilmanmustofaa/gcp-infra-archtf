terraform {
  required_version = ">= 1.10.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.50.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast2"
}

variable "project_id" {
  description = "The project ID to deploy resources into."
  type        = string
}

module "this" {
  source = "../../"

  project_id      = var.project_id
  resource_prefix = "demo"
  join_separator  = "-"

  default_labels = {
    env     = "dev"
    project = "demo"
    owner   = "platform"
  }

  topics = {
    # Event topic (e.g. logging-sink Pub/Sub destination, or app events).
    events = {
      name = "app-events"
      iam_members = {
        publisher = {
          role   = "roles/pubsub.publisher"
          member = "serviceAccount:app@${var.project_id}.iam.gserviceaccount.com"
        }
      }
    }
    # Dead-letter topic for failed deliveries.
    dlq = {
      name = "app-events-dlq"
    }
  }

  subscriptions = {
    worker = {
      name                  = "app-events-worker"
      topic                 = "events" # logical key resolves to the topic above
      ack_deadline_seconds  = 30
      dead_letter_topic     = "projects/${var.project_id}/topics/demo-app-events-dlq"
      max_delivery_attempts = 5
      iam_members = {
        subscriber = {
          role   = "roles/pubsub.subscriber"
          member = "serviceAccount:worker@${var.project_id}.iam.gserviceaccount.com"
        }
      }
    }
  }
}
