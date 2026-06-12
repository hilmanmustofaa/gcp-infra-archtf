locals {
  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "bigquery-googleapis-com--dataset"
    gcp_service    = "bigquery-googleapis-com"
    tf_module      = "bq-dataset"
    tf_layer       = "data"
    tf_resource    = "dataset"
  }

  finops_labels = merge(
    local.finops_labels_default,
    var.default_labels,
  )

  # Final dataset_id (optionally prefixed; '-' -> '_' since BQ ids are underscore-only).
  dataset_id = {
    for k, v in var.datasets : k => (
      var.resource_prefix != null
      ? "${replace(var.resource_prefix, "-", "_")}_${v.dataset_id}"
      : v.dataset_id
    )
  }

  # Flatten datasets x iam_members for for_each.
  iam_members = merge([
    for dk, dv in var.datasets : {
      for mk, mv in dv.iam_members :
      "${dk}/${mk}" => { dataset_key = dk, role = mv.role, member = mv.member }
    }
  ]...)
}

resource "google_bigquery_dataset" "datasets" {
  for_each = var.datasets

  project    = var.project_id
  dataset_id = local.dataset_id[each.key]
  location   = each.value.location

  description                     = each.value.description
  default_table_expiration_ms     = each.value.default_table_expiration_ms
  default_partition_expiration_ms = each.value.default_partition_expiration_ms
  max_time_travel_hours           = each.value.max_time_travel_hours
  delete_contents_on_destroy      = each.value.delete_contents_on_destroy

  labels = merge(local.finops_labels, each.value.labels)

  dynamic "default_encryption_configuration" {
    for_each = each.value.kms_key_name != null ? [each.value.kms_key_name] : []
    content {
      kms_key_name = default_encryption_configuration.value
    }
  }
}

resource "google_bigquery_dataset_iam_member" "members" {
  for_each = local.iam_members

  project    = var.project_id
  dataset_id = google_bigquery_dataset.datasets[each.value.dataset_key].dataset_id
  role       = each.value.role
  member     = each.value.member
}
