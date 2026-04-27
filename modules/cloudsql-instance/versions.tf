terraform {
  required_version = ">= 1.3.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.13.9, < 7.29.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.13.9, < 7.0.0"
    }
  }
}
