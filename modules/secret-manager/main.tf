locals {
  # ===== FinOps labels. =====
  # Refer to Cloud Asset Inventory asset types:
  # https://cloud.google.com/asset-inventory/docs/asset-types
  finops_labels_default = {
    gcp_asset_type = "secretmanager-googleapis-com--secret"
    gcp_service    = "secretmanager-googleapis-com"
    tf_module      = "secret-manager"
    tf_layer       = "security"
    tf_resource    = "secret"
  }

  finops_labels = merge(
    local.finops_labels_default,
    var.default_labels,
  )

  # Flatten secrets x iam_bindings into a single map for for_each.
  iam_bindings = merge([
    for sk, sv in var.secrets : {
      for bk, bv in sv.iam_bindings :
      "${sk}/${bk}" => {
        secret_key = sk
        role       = bv.role
        members    = bv.members
      }
    }
  ]...)

  # Flatten secrets x iam_members into a single map for for_each.
  iam_members = merge([
    for sk, sv in var.secrets : {
      for mk, mv in sv.iam_members :
      "${sk}/${mk}" => {
        secret_key = sk
        role       = mv.role
        member     = mv.member
      }
    }
  ]...)

  # Secrets that carry an initial bootstrap value.
  secret_versions = {
    for k, v in var.secrets : k => v if v.secret_data != null
  }
}

resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets

  project     = var.project_id
  secret_id   = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.secret_id]) : each.value.secret_id
  labels      = merge(local.finops_labels, each.value.labels)
  annotations = each.value.annotations

  replication {
    dynamic "auto" {
      for_each = each.value.replication.automatic ? [""] : []
      content {}
    }

    dynamic "user_managed" {
      for_each = length(each.value.replication.user_managed_replicas) > 0 ? [""] : []
      content {
        dynamic "replicas" {
          for_each = each.value.replication.user_managed_replicas
          content {
            location = replicas.value.location

            dynamic "customer_managed_encryption" {
              for_each = replicas.value.kms_key_name != null ? [""] : []
              content {
                kms_key_name = replicas.value.kms_key_name
              }
            }
          }
        }
      }
    }
  }

  dynamic "rotation" {
    for_each = each.value.rotation != null ? [each.value.rotation] : []
    content {
      next_rotation_time = rotation.value.next_rotation_time
      rotation_period    = rotation.value.rotation_period
    }
  }

  dynamic "topics" {
    for_each = each.value.topics
    content {
      name = topics.value
    }
  }

  ttl             = each.value.ttl
  expire_time     = each.value.expire_time
  version_aliases = each.value.version_aliases
}

resource "google_secret_manager_secret_version" "versions" {
  for_each = local.secret_versions

  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value.secret_data
}

resource "google_secret_manager_secret_iam_binding" "bindings" {
  for_each = local.iam_bindings

  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_key].secret_id
  role      = each.value.role
  members   = each.value.members
}

resource "google_secret_manager_secret_iam_member" "members" {
  for_each = local.iam_members

  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_key].secret_id
  role      = each.value.role
  member    = each.value.member
}
