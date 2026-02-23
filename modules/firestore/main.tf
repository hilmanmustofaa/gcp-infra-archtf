locals {
  database_name_formatted = (var.database.name == "(default)" || var.resource_prefix == null) ? var.database.name : join(var.join_separator, [var.resource_prefix, var.database.name])
  firestore_database_name = var.database_create ? google_firestore_database.firestore_database[0].name : local.database_name_formatted
}

resource "google_firestore_database" "firestore_database" {
  count                             = var.database_create ? 1 : 0
  provider                          = google-beta
  project                           = var.project_id
  name                              = local.database_name_formatted
  location_id                       = var.database.location_id
  type                              = var.database.type
  concurrency_mode                  = var.database.concurrency_mode
  app_engine_integration_mode       = var.database.app_engine_integration_mode
  point_in_time_recovery_enablement = var.database.point_in_time_recovery_enablement
  delete_protection_state           = var.database.delete_protection_state
  deletion_policy                   = var.database.deletion_policy

  dynamic "cmek_config" {
    for_each = var.database.kms_key_name == null ? [] : [""]
    content {
      kms_key_name = var.database.kms_key_name
    }
  }
  lifecycle {
    precondition {
      condition     = var.database.type != null && contains(["DATASTORE_MODE", "FIRESTORE_NATIVE"], var.database.type)
      error_message = "Invalid type. Possible values: DATASTORE_MODE, FIRESTORE_NATIVE"
    }
    precondition {
      condition     = var.database.location_id != null
      error_message = "location_id must be set."
    }
  }
}

resource "google_firestore_backup_schedule" "firestore_backup_schedule" {
  count     = var.backup_schedule == null ? 0 : 1
  project   = var.project_id
  database  = local.firestore_database_name
  retention = var.backup_schedule.retention

  dynamic "daily_recurrence" {
    for_each = var.backup_schedule.daily_recurrence ? [""] : []
    content {

    }
  }

  dynamic "weekly_recurrence" {
    for_each = var.backup_schedule.weekly_recurrence == null ? [] : [""]
    content {
      day = var.backup_schedule.weekly_recurrence
    }
  }
}

resource "google_firestore_field" "firestore_fields" {
  for_each   = var.fields
  project    = var.project_id
  database   = local.firestore_database_name
  collection = each.value.collection
  field      = each.value.field

  dynamic "index_config" {
    for_each = each.value.indexes == null ? [] : [""]
    content {
      dynamic "indexes" {
        for_each = each.value.indexes
        content {
          query_scope  = indexes.value.query_scope
          order        = indexes.value.order
          array_config = indexes.value.array_config
        }
      }
    }
  }
  dynamic "ttl_config" {
    for_each = each.value.ttl_config ? [""] : []
    content {

    }
  }
}

resource "google_firestore_document" "firestore_documents" {
  for_each    = var.documents
  project     = var.project_id
  database    = local.firestore_database_name
  collection  = each.value.collection
  document_id = each.value.document_id
  fields      = jsonencode(each.value.fields)
}

resource "google_firestore_index" "firestore_indexes" {
  for_each   = var.indexes
  project    = var.project_id
  database   = local.firestore_database_name
  collection = each.value.collection
  dynamic "fields" {
    for_each = each.value.fields
    content {
      field_path   = fields.value.field_path
      order        = fields.value.order
      array_config = fields.value.array_config
      dynamic "vector_config" {
        for_each = fields.value.vector_config == null ? [] : [""]
        content {
          dimension = fields.value.vector_config.dimension
          dynamic "flat" {
            for_each = fields.value.vector_config.flat ? [""] : []
            content {

            }
          }
        }
      }
    }
  }
}
