run "plan_iam_bindings" {
  command = plan

  variables {
    resource_prefix = "test"

    kms_key_rings = {
      kr-iam = {
        name     = "iam-keyring"
        location = "us-central1"
        project  = "test-project"
      }
    }

    kms_crypto_keys = {
      iam-key = {
        name             = "iam-key"
        key_ring         = "kr-iam"
        purpose          = "ENCRYPT_DECRYPT"
        rotation_period  = "7776000s"
        labels           = {}
        version_template = null
      }
    }

    kms_crypto_key_iam_bindings = {
      binding-1 = {
        crypto_key_id = "iam-key"
        role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        memebers      = ["serviceAccount:test@test-project.iam.gserviceaccount.com"]
        condition     = null
      }
    }

    kms_crypto_key_iam_members = {
      member-1 = {
        crypto_key_id = "iam-key"
        role          = "roles/cloudkms.cryptoKeyEncrypter"
        member        = "serviceAccount:app@test-project.iam.gserviceaccount.com"
        condition     = null
      }
    }
  }

  # Verify Crypto Key
  assert {
    condition     = google_kms_crypto_key.kms_crypto_keys["iam-key"].name == "test-iam-key"
    error_message = "Crypto key name incorrect"
  }

  # Verify IAM Binding
  assert {
    condition     = google_kms_crypto_key_iam_binding.kms_crypto_key_iam_bindings["binding-1"].role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    error_message = "IAM binding role incorrect"
  }

  # Verify IAM Member
  assert {
    condition     = google_kms_crypto_key_iam_member.kms_crypto_key_iam_members["member-1"].role == "roles/cloudkms.cryptoKeyEncrypter"
    error_message = "IAM member role incorrect"
  }

  assert {
    condition     = google_kms_crypto_key_iam_member.kms_crypto_key_iam_members["member-1"].member == "serviceAccount:app@test-project.iam.gserviceaccount.com"
    error_message = "IAM member incorrect"
  }
}
