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

module "dns_public" {
  source = "../../"

  project_id = var.project_id

  default_labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  dns_managed_zones = {
    example-com = {
      name        = "example-com"
      dns_name    = "example.com."
      description = "Public zone for example.com"
      visibility  = "public"
      labels = {
        team = "web"
      }
    }
  }

  dns_record_sets = {
    www = {
      name         = "www"
      type         = "A"
      ttl          = 300
      managed_zone = "example-com"
      rrdatas      = ["1.2.3.4"]
    }
    api = {
      name         = "api"
      type         = "CNAME"
      ttl          = 300
      managed_zone = "example-com"
      rrdatas      = ["api.backend.com."]
    }
  }
}
