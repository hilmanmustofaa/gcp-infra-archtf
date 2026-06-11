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

  # IAP tunnel access (SSH/RDP) to a bastion VM.
  tunnel_instance_bindings = {
    bastion = {
      zone     = "asia-southeast2-a"
      instance = "bastion-host"
      members  = ["group:sre@example.com"]
    }
  }

  # IAP-protected web app behind an external HTTPS load balancer.
  web_backend_bindings = {
    app = {
      web_backend_service = "app-backend"
      members             = ["domain:example.com"]
    }
  }

  # Brand creation is OFF by default (singleton + deprecated API). Manage the
  # OAuth consent brand once per project outside this module.
  create_brand = false
}
