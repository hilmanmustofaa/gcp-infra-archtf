terraform {
  required_version = ">= 1.10.2"

  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = ">= 6.50.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = "us-central1"
}

variable "project_id" {
  description = "The ID of the project."
  type        = string
}

resource "google_compute_instance_template" "default" {
  name_prefix  = "regional-template-"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
  }
}

module "regional_mig" {
  source = "../../"

  project_id        = var.project_id
  name              = "regional-mig-autoscaling"
  location          = "us-central1"
  instance_template = google_compute_instance_template.default.self_link
  target_size       = 1 # Initial size, managed by autoscaler

  autoscaler_config = {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    scaling_signals = {
      cpu_utilization = {
        target = 0.7
      }
    }
  }

  update_policy = {
    minimal_action = "REPLACE"
    type           = "PROACTIVE"
    max_surge      = { fixed = 3 }
    min_ready_sec  = 60
  }
}
