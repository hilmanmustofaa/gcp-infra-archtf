locals {
  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "cloudkms.googleapis.com/CryptoKey"
    gcp_service    = "cloudkms.googleapis.com"
    tf_module      = "kms"
    tf_layer       = "security"
    tf_resource    = "crypto-key"
  }

  # Efficient key ring handling using CFF approach
  key_rings = {
    for k, v in var.kms_key_rings : k => {
      id       = google_kms_key_ring.kms_key_rings[k].id
      name     = v.name
      location = v.location
      project  = v.project
    }
  }

  # Merge data and resource key rings for lookup
  all_key_rings = merge(
    local.key_rings,
    {
      for k, v in data.google_kms_key_ring.kms_key_rings : k => {
        id       = v.id
        name     = v.name
        location = v.location
        project  = v.project
      }
    }
  )
}

# Data sources remain the same for backward compatibility
data "google_kms_crypto_key" "kms_crypto_keys" {
  provider = google
  for_each = var.data_kms_crypto_keys
  name     = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  key_ring = local.all_key_rings[each.value.key_ring].id
}

data "google_kms_key_ring" "kms_key_rings" {
  provider = google
  for_each = var.data_kms_key_rings
  name     = each.value.project != null ? each.value.name : var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  location = each.value.location
  project  = each.value.project
}

# Key rings using CFF-style configuration
resource "google_kms_key_ring" "kms_key_rings" {
  provider = google
  for_each = var.kms_key_rings
  name     = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  location = each.value.location
  project  = each.value.project
}

# Crypto keys with improved version template handling from CFF
resource "google_kms_crypto_key" "kms_crypto_keys" {
  provider = google
  for_each = var.kms_crypto_keys
  name     = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  key_ring = local.all_key_rings[each.value.key_ring].id
  labels = merge(
    local.finops_labels_default,
    var.default_labels,
    each.value.labels,
    {
      "name"      = each.value.name
      "component" = "cryptokey"
    }
  )
  purpose                       = each.value.purpose
  rotation_period               = each.value.rotation_period
  destroy_scheduled_duration    = each.value.destroy_scheduled_duration
  import_only                   = each.value.import_only
  skip_initial_version_creation = each.value.skip_initial_version_creation

  dynamic "version_template" {
    for_each = each.value.version_template != null ? [""] : []
    content {
      algorithm        = each.value.version_template.algorithm
      protection_level = each.value.version_template.protection_level
    }
  }
}

# IAM bindings with improved error handling
resource "google_kms_crypto_key_iam_binding" "kms_crypto_key_iam_bindings" {
  provider      = google-beta
  for_each      = var.kms_crypto_key_iam_bindings
  crypto_key_id = google_kms_crypto_key.kms_crypto_keys[each.value.crypto_key_id].id
  members       = each.value.memebers
  role          = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_kms_crypto_key_iam_member" "kms_crypto_key_iam_members" {
  provider      = google-beta
  for_each      = var.kms_crypto_key_iam_members
  crypto_key_id = google_kms_crypto_key.kms_crypto_keys[each.value.crypto_key_id].id
  member        = each.value.member
  role          = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
