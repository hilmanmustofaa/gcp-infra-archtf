locals {
  service_account_email = (
    var.service_account_create
    ? google_service_account.service_accounts[0].email
    : try(data.google_service_account.service_accounts[0].email, null)
  )
  account_id_formatted  = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, var.account_id]) : var.account_id
  resource_email_static = "${local.account_id_formatted}@${var.project_id}.iam.gserviceaccount.com"
  resource_iam_email = (
    local.service_account_email != null
    ? "serviceAccount:${local.service_account_email}"
    : local.resource_iam_email_static
  )
  resource_iam_email_static = "serviceAccount:${local.resource_email_static}"

  # Full resource name for IAM resources (required by newer provider validation).
  service_account_id_full = (
    local.service_account_email != null
    ? "projects/${var.project_id}/serviceAccounts/${local.service_account_email}"
    : "projects/${var.project_id}/serviceAccounts/${local.resource_email_static}"
  )

  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "iam.googleapis.com/ServiceAccount"
    gcp_service    = "iam.googleapis.com"
    tf_module      = "iam-service-account"
    tf_layer       = "identity"
    tf_resource    = "service_account"
  }

  finops_labels = merge(
    local.finops_labels_default,
    var.labels,
  )
}

data "google_service_account" "service_accounts" {
  count      = var.service_account_create ? 0 : 1
  project    = var.project_id
  account_id = local.account_id_formatted
}

resource "google_service_account" "service_accounts" {
  count        = var.service_account_create ? 1 : 0
  project      = var.project_id
  account_id   = local.account_id_formatted
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
}

resource "google_service_account_key" "keys" {
  count              = var.generate_key ? 1 : 0
  service_account_id = local.service_account_id_full
}

resource "google_service_account_iam_binding" "bindings" {
  for_each = var.iam_bindings

  service_account_id = local.service_account_id_full
  role               = each.value.role
  members            = each.value.members

  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [""]
    content {
      expression  = each.value.condition.expression
      title       = each.value.condition.title
      description = each.value.condition.description
    }
  }
}

resource "google_service_account_iam_member" "bindings" {
  for_each = var.iam_bindings_additive

  service_account_id = local.service_account_id_full
  role               = each.value.role
  member             = each.value.member

  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [""]
    content {
      expression  = each.value.condition.expression
      title       = each.value.condition.title
      description = each.value.condition.description
    }
  }
}

# Project level IAM.
resource "google_project_iam_member" "project_iam_members" {
  for_each = var.project_iam_bindings

  project = coalesce(each.value.project, var.project_id)
  role    = each.value.role
  member  = local.resource_iam_email
}

# Storage bucket level IAM.
resource "google_storage_bucket_iam_member" "storage_bucket_iam_members" {
  for_each = var.storage_bucket_iam_bindings

  bucket = each.value.bucket
  role   = each.value.role
  member = local.resource_iam_email
}
