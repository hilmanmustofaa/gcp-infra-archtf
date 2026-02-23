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
  description = "Project id where service account will be created."
  type        = string
}

module "service_account_basic" {
  source = "../../"

  project_id = var.project_id
  account_id = "app-basic-sa"

  display_name = "Basic application service account."
  description  = "Service account used by a basic application."
  disabled     = false
  prefix       = ""

  service_account_create = true
  generate_key           = false

  iam_bindings                = {}
  iam_bindings_additive       = {}
  project_iam_bindings        = {}
  storage_bucket_iam_bindings = {}

  labels = {
    environment = "dev"
    application = "demo-basic"
  }
}
