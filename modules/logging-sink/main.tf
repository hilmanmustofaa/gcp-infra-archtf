locals {
  # Build the fully-qualified sink destination URI from type + short name.
  sink_destinations = {
    for k, v in var.sinks : k => (
      v.destination_type == "bigquery" ? "bigquery.googleapis.com/projects/${coalesce(v.destination_project, var.project_id)}/datasets/${v.destination}" :
      v.destination_type == "gcs" ? "storage.googleapis.com/${v.destination}" :
      "pubsub.googleapis.com/projects/${coalesce(v.destination_project, var.project_id)}/topics/${v.destination}"
    )
  }

  # Per-destination subsets that require a writer-identity IAM grant.
  bq_grants = {
    for k, v in var.sinks : k => v
    if v.destination_type == "bigquery" && v.grant_destination_permission
  }
  gcs_grants = {
    for k, v in var.sinks : k => v
    if v.destination_type == "gcs" && v.grant_destination_permission
  }
  pubsub_grants = {
    for k, v in var.sinks : k => v
    if v.destination_type == "pubsub" && v.grant_destination_permission
  }
}

resource "google_logging_project_sink" "sinks" {
  for_each = var.sinks

  project                = var.project_id
  name                   = each.value.name
  destination            = local.sink_destinations[each.key]
  filter                 = each.value.filter
  description            = each.value.description
  disabled               = each.value.disabled
  unique_writer_identity = each.value.unique_writer_identity

  dynamic "bigquery_options" {
    for_each = each.value.destination_type == "bigquery" && each.value.use_partitioned_tables != null ? [""] : []
    content {
      use_partitioned_tables = each.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions
    content {
      name        = exclusions.key
      filter      = exclusions.value.filter
      description = exclusions.value.description
      disabled    = exclusions.value.disabled
    }
  }
}

# ── Writer-identity grants on the (pre-existing) destinations ─────────────────

resource "google_bigquery_dataset_iam_member" "bq" {
  for_each = local.bq_grants

  project    = coalesce(each.value.destination_project, var.project_id)
  dataset_id = each.value.destination
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.sinks[each.key].writer_identity
}

resource "google_storage_bucket_iam_member" "gcs" {
  for_each = local.gcs_grants

  bucket = each.value.destination
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.sinks[each.key].writer_identity
}

resource "google_pubsub_topic_iam_member" "pubsub" {
  for_each = local.pubsub_grants

  project = coalesce(each.value.destination_project, var.project_id)
  topic   = each.value.destination
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.sinks[each.key].writer_identity
}
