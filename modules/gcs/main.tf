locals {
  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "storage.googleapis.com/Bucket"
    gcp_service    = "storage.googleapis.com"
    tf_module      = "gcs-bucket"
    tf_layer       = "storage"
    tf_resource    = "bucket"
  }

  # Default labels applied to all buckets (FinOps + user-supplied).
  bucket_labels_default = merge(
    local.finops_labels_default,
    var.default_labels,
  )
}

resource "google_storage_bucket" "storage_buckets" {
  provider = google
  for_each = var.storage_buckets

  project  = var.project_id
  name     = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  location = each.value.location

  # Merge FinOps + default_labels + per-bucket labels.
  labels        = merge(local.bucket_labels_default, each.value.labels)
  force_destroy = each.value.force_destroy

  uniform_bucket_level_access = coalesce(each.value.uniform_bucket_level_access, true)
  public_access_prevention    = try(each.value.public_access_prevention, "inherited")
  storage_class               = each.value.storage_class

  versioning {
    enabled = try(each.value.versioning.enabled, false)
  }

  dynamic "autoclass" {
    for_each = try(each.value.autoclass, null) != null ? [""] : []
    content {
      enabled = each.value.autoclass
    }
  }

  dynamic "encryption" {
    for_each = try(each.value.encryption, null) != null ? [each.value.encryption] : []
    content {
      default_kms_key_name = encryption.value.kms_key_name
    }
  }

  dynamic "lifecycle_rule" {
    for_each = coalesce(each.value.lifecycle_rules, {})
    iterator = rule
    content {
      action {
        type          = rule.value.action.type
        storage_class = rule.value.action.storage_class
      }
      condition {
        age                        = rule.value.condition.age
        created_before             = rule.value.condition.created_before
        custom_time_before         = rule.value.condition.custom_time_before
        days_since_custom_time     = rule.value.condition.days_since_custom_time
        days_since_noncurrent_time = rule.value.condition.days_since_noncurrent_time
        matches_prefix             = rule.value.condition.matches_prefix
        matches_storage_class      = rule.value.condition.matches_storage_class
        matches_suffix             = rule.value.condition.matches_suffix
        noncurrent_time_before     = rule.value.condition.noncurrent_time_before
        num_newer_versions         = rule.value.condition.num_newer_versions
        with_state                 = rule.value.condition.with_state
      }
    }
  }

  dynamic "retention_policy" {
    for_each = each.value.retention_policy.retention_period != null ? [""] : []
    content {
      is_locked        = try(each.value.retention_policy.is_locked, false)
      retention_period = each.value.retention_policy.retention_period
    }
  }

  dynamic "logging" {
    for_each = each.value.logging.log_bucket != null ? [""] : []
    content {
      log_bucket        = each.value.logging.log_bucket
      log_object_prefix = each.value.logging.log_object_prefix
    }
  }

  dynamic "website" {
    for_each = each.value.website != null ? [""] : []
    content {
      main_page_suffix = each.value.website.main_page_suffix
      not_found_page   = each.value.website.not_found_page
    }
  }

  dynamic "custom_placement_config" {
    for_each = each.value.custom_placement_config != null ? [""] : []
    content {
      data_locations = each.value.custom_placement_config
    }
  }
}

# Object upload support.
resource "google_storage_bucket_object" "objects" {
  for_each = var.objects

  bucket              = google_storage_bucket.storage_buckets[each.value.bucket].name
  name                = each.value.name
  metadata            = each.value.metadata
  content             = each.value.content
  source              = each.value.source
  cache_control       = each.value.cache_control
  content_disposition = each.value.content_disposition
  content_encoding    = each.value.content_encoding
  content_language    = each.value.content_language
  content_type        = each.value.content_type
  storage_class       = each.value.storage_class

  dynamic "customer_encryption" {
    for_each = each.value.customer_encryption == null ? [] : [""]
    content {
      encryption_algorithm = each.value.customer_encryption.encryption_algorithm
      encryption_key       = each.value.customer_encryption.encryption_key
    }
  }
}
