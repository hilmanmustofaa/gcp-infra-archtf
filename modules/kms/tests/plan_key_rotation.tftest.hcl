run "plan_key_rotation" {
  command = plan

  variables {
    resource_prefix = "prod"

    kms_key_rings = {
      kr-rotation = {
        name     = "rotation-keyring"
        location = "us-east1"
        project  = "test-project"
      }
    }

    kms_crypto_keys = {
      rotating-key = {
        name            = "rotating-key"
        key_ring        = "kr-rotation"
        purpose         = "ENCRYPT_DECRYPT"
        rotation_period = "2592000s"
        labels          = {}
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "SOFTWARE"
        }
      }
    }
  }

  # Verify Key Ring
  assert {
    condition     = google_kms_key_ring.kms_key_rings["kr-rotation"].name == "prod-rotation-keyring"
    error_message = "Key ring name incorrect"
  }

  # Verify Crypto Key
  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["rotating-key"].name == "prod-rotating-key"
    error_message = "Crypto key name incorrect"
  }

  # Verify Rotation Period (30 days)
  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["rotating-key"].rotation_period == "2592000s"
    error_message = "Rotation period should be 2592000s (30 days)"
  }

  # Verify Version Template
  assert {
    condition     = length(google_kms_crypto_key.kms_crypto_keys["rotating-key"].version_template) > 0
    error_message = "Version template should be configured"
  }
}
