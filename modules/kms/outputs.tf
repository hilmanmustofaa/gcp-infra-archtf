output "crypto_keys" {
  description = "Map of created crypto keys."
  value = {
    for k, v in google_kms_crypto_key.kms_crypto_keys : k => {
      id               = v.id
      name             = v.name
      key_ring         = v.key_ring
      rotation_period  = v.rotation_period
      purpose          = v.purpose
      version_template = v.version_template
    }
  }
}

output "iam_bindings" {
  description = "Map of IAM bindings created."
  value = {
    for k, v in google_kms_crypto_key_iam_binding.kms_crypto_key_iam_bindings : k => {
      crypto_key_id = v.crypto_key_id
      role          = v.role
      members       = v.members
      condition     = v.condition
    }
  }
}

output "iam_members" {
  description = "Map of IAM members created."
  value = {
    for k, v in google_kms_crypto_key_iam_member.kms_crypto_key_iam_members : k => {
      crypto_key_id = v.crypto_key_id
      role          = v.role
      member        = v.member
      condition     = v.condition
    }
  }
}

output "imported_crypto_keys" {
  description = "Map of imported crypto keys."
  value = {
    for k, v in data.google_kms_crypto_key.kms_crypto_keys : k => {
      id       = v.id
      name     = v.name
      key_ring = v.key_ring
    }
  }
}

output "imported_key_rings" {
  description = "Map of imported key rings."
  value = {
    for k, v in data.google_kms_key_ring.kms_key_rings : k => {
      id       = v.id
      name     = v.name
      location = v.location
      project  = v.project
    }
  }
}

output "key_rings" {
  description = "Map of created key rings."
  value = {
    for k, v in google_kms_key_ring.kms_key_rings : k => {
      id       = v.id
      name     = v.name
      location = v.location
      project  = v.project
    }
  }
}
