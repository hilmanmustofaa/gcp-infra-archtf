# ============================================================================
# E2E Scenario: pubsub-topic
# ----------------------------------------------------------------------------
# Real apply blueprint (project: toylabs). Creates a Pub/Sub topic + a
# dead-letter topic + a pull subscription with a dead-letter policy + additive
# topic IAM via the pubsub-topic module, then tears it down. Validates the
# logical-key topic resolution and dead-letter wiring end-to-end.
#
# Destroy strategy: applied then destroyed by `task e2e:toylabs`. Run-scoped
# random_id suffix keeps names unique. All resources carry env=e2e-toylabs.
# ============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.13.9, < 7.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

variable "project_id" {
  description = "Target project for the e2e apply."
  type        = string
  default     = "toylabs"
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast2"
}

resource "random_id" "suffix" {
  byte_length = 3
}

data "google_project" "this" {
  project_id = var.project_id
}

locals {
  labels = {
    env     = "e2e-toylabs"
    project = "module-library"
    owner   = "ci"
  }
  prefix   = "e2e-${random_id.suffix.hex}"
  dlq_name = "${local.prefix}-events-dlq"
  # Impersonal, always-valid principal for the IAM smoke test (default compute SA).
  test_member = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}

module "pubsub" {
  source = "../../modules/pubsub-topic"

  project_id      = var.project_id
  resource_prefix = local.prefix
  default_labels  = local.labels

  topics = {
    events = {
      name = "events"
      iam_members = {
        publisher = {
          role   = "roles/pubsub.publisher"
          member = local.test_member
        }
      }
    }
    dlq = {
      name = "events-dlq"
    }
  }

  subscriptions = {
    worker = {
      name                  = "events-worker"
      topic                 = "events" # logical key resolves to the topic above
      ack_deadline_seconds  = 30
      dead_letter_topic     = "projects/${var.project_id}/topics/${local.dlq_name}"
      max_delivery_attempts = 5
    }
  }
}

output "topic_id" {
  value = module.pubsub.topic_ids["events"]
}

output "subscription_id" {
  value = module.pubsub.subscription_ids["worker"]
}
