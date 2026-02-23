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

module "basic_service" {
  source = "../../"

  project_id = var.project_id
  region     = "us-central1"
  name       = "hello-world-v2"

  containers = {
    app = {
      image = "gcr.io/google-samples/hello-app:1.0"
      ports = {
        http = {
          container_port = 8080
        }
      }
    }
  }

  default_labels = {
    env = "dev"
  }

  labels = {
    team = "platform"
  }
}
