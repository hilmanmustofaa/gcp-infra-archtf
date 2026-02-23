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

variable "rotation_period_days" {
  description = "Number of days between automatic key rotations."
  type        = number
  default     = 90
}

module "kms_rotation" {
  source = "../../"

  resource_prefix = "prod"

  default_labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  kms_key_rings = {
    secure-keyring = {
      name     = "secure-keyring"
      location = var.location
      project  = var.project_id
    }
  }

  kms_crypto_keys = {
    rotating-key = {
      name            = "auto-rotating-key"
      key_ring        = "secure-keyring"
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "${var.rotation_period_days * 86400}s"
      labels = {
        security = "high"
        rotation = "enabled"
      }
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
      }
    }
  }
}

output "key_ring_id" {
  description = "The ID of the key ring"
  value       = module.kms_rotation.key_rings["secure-keyring"].id
}

output "crypto_key_id" {
  description = "The ID of the crypto key"
  value       = module.kms_rotation.crypto_keys["rotating-key"].id
}

output "rotation_period" {
  description = "The rotation period in seconds"
  value       = module.kms_rotation.crypto_keys["rotating-key"].rotation_period
}
