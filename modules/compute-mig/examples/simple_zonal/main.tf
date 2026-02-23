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
  name_prefix  = "mig-template-"
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

module "zonal_mig" {
  source = "../../"

  project_id        = var.project_id
  name              = "simple-zonal-mig"
  location          = "us-central1-a"
  instance_template = google_compute_instance_template.default.self_link
  target_size       = 2

  auto_healing_policies = {
    initial_delay_sec = 300
  }
}
