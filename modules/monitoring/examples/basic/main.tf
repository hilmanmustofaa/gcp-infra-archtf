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

  project_id = var.project_id

  default_labels = {
    env     = "dev"
    project = "demo"
    owner   = "platform"
  }

  notification_channels = {
    email = {
      display_name = "SRE Email"
      type         = "email"
      labels       = { email_address = "sre@example.com" }
    }
  }

  alert_policies = {
    cpu = {
      display_name          = "High CPU utilization"
      combiner              = "OR"
      notification_channels = ["email"]
      conditions = [
        {
          display_name = "CPU > 80% for 5m"
          condition_threshold = {
            filter           = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
            comparison       = "COMPARISON_GT"
            threshold_value  = 0.8
            duration         = "300s"
            alignment_period = "60s"
          }
        }
      ]
    }
  }

  uptime_checks = {
    api = {
      display_name = "API health"
      monitored_resource = {
        type = "uptime_url"
        labels = {
          host       = "api.example.com"
          project_id = var.project_id
        }
      }
      http_check = {
        path    = "/healthz"
        port    = 443
        use_ssl = true
      }
    }
  }
}
