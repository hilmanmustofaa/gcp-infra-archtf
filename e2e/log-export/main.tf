# ============================================================================
# E2E Scenario: log-export
# ----------------------------------------------------------------------------
# Real apply blueprint (project: toylabs). Composes the gcs module (a bucket
# with Autoclass) with the logging-sink module (export audit logs to that
# bucket + writer-identity IAM grant). Validates the "destination must
# pre-exist" composition story end-to-end.
#
# Destroy strategy: applied then destroyed by `task e2e:toylabs`. force_destroy
# is on so the bucket tears down even if a log object was written. All
# resources carry env=e2e-toylabs.
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

locals {
  labels = {
    env     = "e2e-toylabs"
    project = "module-library"
    owner   = "ci"
  }
  bucket_name = "e2e-log-archive-${random_id.suffix.hex}"
}

# Destination (must pre-exist before the sink references it) — with Autoclass.
module "gcs" {
  source = "../../modules/gcs"

  project_id     = var.project_id
  default_labels = local.labels

  storage_buckets = {
    logs = {
      name          = local.bucket_name
      location      = "ASIA-SOUTHEAST2"
      force_destroy = true
      autoclass = {
        enabled                = true
        terminal_storage_class = "NEARLINE"
      }
    }
  }
}

# Sink exporting audit logs to the bucket + writer-identity grant.
module "logging_sink" {
  source = "../../modules/logging-sink"

  project_id = var.project_id

  sinks = {
    audit = {
      name             = "e2e-audit-to-gcs-${random_id.suffix.hex}"
      destination_type = "gcs"
      destination      = module.gcs.names["logs"]
      filter           = "logName:\"cloudaudit.googleapis.com\""
    }
  }
}

output "bucket" {
  value = module.gcs.names["logs"]
}

output "sink_destination" {
  value = module.logging_sink.sink_destinations["audit"]
}
