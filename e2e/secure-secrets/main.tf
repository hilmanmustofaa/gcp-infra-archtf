# ============================================================================
# E2E Scenario: secure-secrets
# ----------------------------------------------------------------------------
# Real apply blueprint (project: toylabs). Provisions a Secret Manager secret
# with automatic replication + a rotation Pub/Sub topic, plus a monitoring
# notification channel — the minimal "secure app secrets + alerting" slice.
#
# Doubles as a reference blueprint for composing secret-manager + monitoring.
#
# Destroy strategy: this config holds only ephemeral, cheap resources and is
# applied then destroyed by `task e2e:toylabs`. Every resource carries
# env=e2e-toylabs so `task e2e:destroy` / audits can find strays.
# ============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.13.9, < 7.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
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

provider "google-beta" {
  project = var.project_id
  region  = "asia-southeast2"
}

# Run-scoped suffix so concurrent/repeated runs never collide and strays are
# identifiable.
resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  labels = {
    env     = "e2e-toylabs"
    project = "module-library"
    owner   = "ci"
  }
}

# Pub/Sub topic that receives rotation notifications (destination dependency).
resource "google_pubsub_topic" "rotation" {
  project = var.project_id
  name    = "e2e-secret-rotation-${random_id.suffix.hex}"
  labels  = local.labels
}

# Secret rotation with a topic requires the Secret Manager service agent to be
# able to publish to that topic. This is a project-level dependency that lives
# OUTSIDE the secret-manager module (the module manages secrets, not the P4SA).
resource "google_project_service_identity" "secretmanager" {
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

resource "google_pubsub_topic_iam_member" "sm_publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.rotation.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_project_service_identity.secretmanager.email}"
}

module "secrets" {
  source = "../../modules/secret-manager"

  project_id     = var.project_id
  default_labels = local.labels

  secrets = {
    app = {
      secret_id = "e2e-app-secret-${random_id.suffix.hex}"
      replication = {
        automatic = true
      }
      rotation = {
        rotation_period    = "7776000s"
        next_rotation_time = "2027-01-01T00:00:00Z"
      }
      topics = [google_pubsub_topic.rotation.id]
    }
  }

  # Ensure the service agent can publish before the secret references the topic.
  depends_on = [google_pubsub_topic_iam_member.sm_publisher]
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_id     = var.project_id
  default_labels = local.labels

  notification_channels = {
    email = {
      display_name = "e2e SRE ${random_id.suffix.hex}"
      type         = "email"
      labels       = { email_address = "e2e-sre@example.com" }
    }
  }
}

output "secret_ids" {
  value = module.secrets.secret_ids
}

output "notification_channel_ids" {
  value = module.monitoring.notification_channel_ids
}
