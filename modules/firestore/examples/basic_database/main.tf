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

module "firestore" {
  source = "../../"

  project_id = var.project_id

  database = {
    name        = "my-firestore-db"
    location_id = "us-central1"
    type        = "FIRESTORE_NATIVE"
  }

  documents = {
    "welcome-msg" = {
      collection  = "messages"
      document_id = "welcome"
      fields = {
        title   = { stringValue = "Welcome" }
        content = { stringValue = "Hello, Firestore!" }
        active  = { booleanValue = true }
      }
    }
  }
}
