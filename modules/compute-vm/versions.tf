terraform {
  required_version = ">= 1.3.0"
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.13.9, < 7.20.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.13.9, < 7.0.0"
    }
  }
}
