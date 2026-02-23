terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.49, < 8"

    }
  }
  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-network:network-connectivity-center/v12.0.0"
  }
}