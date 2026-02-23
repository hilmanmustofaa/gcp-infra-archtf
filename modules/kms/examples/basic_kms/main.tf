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
}

variable "project_id" {
  description = "The ID of the project where KMS resources will be created."
  type        = string
}

variable "location" {
  description = "The location for the key ring."
  type        = string
  default     = "us-central1"
}

module "kms" {
  source = "../../"

  resource_prefix = "prod"

  default_labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  kms_key_rings = {
    main-keyring = {
      name     = "main-keyring"
      location = var.location
      project  = var.project_id
    }
  }

  kms_crypto_keys = {
    app-key = {
      name            = "app-encryption-key"
      key_ring        = "main-keyring"
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s"
      labels = {
        app     = "web-application"
        purpose = "data-encryption"
      }
      version_template = null
    }
  }
}

output "key_ring_id" {
  description = "The ID of the key ring"
  value       = module.kms.key_rings["main-keyring"].id
}

output "crypto_key_id" {
  description = "The ID of the crypto key"
  value       = module.kms.crypto_keys["app-key"].id
}

output "crypto_key_name" {
  description = "The name of the crypto key"
  value       = module.kms.crypto_keys["app-key"].name
}
