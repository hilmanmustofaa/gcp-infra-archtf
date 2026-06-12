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
  region = "asia-southeast2"
}

variable "access_policy_id" {
  description = "Existing access policy id, e.g. accessPolicies/123456789."
  type        = string
}

variable "perimeter_project_number" {
  description = "Project number to enclose, e.g. projects/123456789."
  type        = string
}

module "this" {
  source = "../../"

  access_policy_id = var.access_policy_id

  default_labels = {
    env     = "prod"
    project = "secure-data"
    owner   = "security-team"
  }

  access_levels = {
    # Trusted corporate network + region restriction.
    corp = {
      title = "Corp network (ID only)"
      conditions = [
        {
          ip_subnetworks = ["203.0.113.0/24"]
          regions        = ["ID"]
        }
      ]
    }
  }

  service_perimeters = {
    # Data-exfiltration boundary around the data project.
    data = {
      title               = "Secured data tier"
      resources           = [var.perimeter_project_number]
      restricted_services = ["bigquery.googleapis.com", "storage.googleapis.com"]
      access_levels       = ["corp"]
      vpc_accessible_services = {
        enable_restriction = true
        allowed_services   = ["bigquery.googleapis.com", "storage.googleapis.com"]
      }
    }
  }
}
