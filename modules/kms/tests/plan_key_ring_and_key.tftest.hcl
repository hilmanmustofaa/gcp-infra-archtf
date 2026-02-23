run "plan_key_ring_and_key" {
  command = plan

  variables {
    resource_prefix = "test"

    default_labels = {
      environment = "test"
      managed_by  = "terraform"
    }

    kms_key_rings = {
      kr-1 = {
        name     = "keyring-1"
        location = "us-central1"
        project  = "test-project"
      }
    }

    kms_crypto_keys = {
      key-1 = {
        name            = "crypto-key-1"
        key_ring        = "kr-1"
        purpose         = "ENCRYPT_DECRYPT"
        rotation_period = "7776000s"
        labels = {
          app  = "web"
          tier = "production"
        }
        version_template = null
      }
    }
  }

  # Verify Key Ring
  assert {
    condition     = google_kms_key_ring.kms_key_rings["kr-1"].name == "test-keyring-1"
    error_message = "Key ring name incorrect"
  }

  assert {
    condition     = google_kms_key_ring.kms_key_rings["kr-1"].location == "us-central1"
    error_message = "Key ring location incorrect"
  }

  # Verify Crypto Key
  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["key-1"].name == "test-crypto-key-1"
    error_message = "Crypto key name incorrect"
  }

  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["key-1"].purpose == "ENCRYPT_DECRYPT"
    error_message = "Crypto key purpose incorrect"
  }

  # Verify Default Labels
  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["key-1"].labels["environment"] == "test"
    error_message = "Should have default label environment=test"
  }

  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["key-1"].labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  # Verify Specific Labels
  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["key-1"].labels["app"] == "web"
    error_message = "Should have specific label app=web"
  }

  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["key-1"].labels["tier"] == "production"
    error_message = "Should have specific label tier=production"
  }

  # Verify Automatic Labels
  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["key-1"].labels["name"] == "crypto-key-1"
    error_message = "Should have automatic label name=crypto-key-1"
  }

  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["key-1"].labels["component"] == "cryptokey"
    error_message = "Should have automatic label component=cryptokey"
  }
}
