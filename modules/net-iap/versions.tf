terraform {
  required_version = ">= 1.9.0" # cross-variable validation conditions
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.13.9, < 7.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.13.9, < 7.0.0"
    }
  }
}
