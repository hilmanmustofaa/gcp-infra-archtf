locals {
  # ========= FinOps module labels (per service module) =========
  # Refer to Cloud Asset Inventory asset types:
  # https://cloud.google.com/asset-inventory/docs/asset-types
  #
  # Artifact Registry repository:
  #   - gcp_asset_type = artifactregistry.googleapis.com/Repository
  #   - gcp_service    = artifactregistry.googleapis.com
  finops_module_labels_default = {
    gcp_asset_type = "artifactregistry.googleapis.com/Repository"
    gcp_service    = "artifactregistry.googleapis.com"

    tf_module   = "artifact-registry"
    tf_layer    = "artifact"
    tf_resource = "repository"
  }

  # Effective labels applied to the repository AND exposed back to caller
  repository_labels = merge(
    local.finops_module_labels_default,
    var.labels
  )

  # Host suffix per format, for convenience URL
  repository_host_suffix = (
    var.format == "DOCKER" ? "docker.pkg.dev" :
    var.format == "MAVEN" ? "maven.pkg.dev" :
    var.format == "NPM" ? "npm.pkg.dev" :
    var.format == "PYTHON" ? "python.pkg.dev" :
    var.format == "APT" ? "apt.pkg.dev" :
    var.format == "YUM" ? "yum.pkg.dev" :
    "pkg.dev"
  )

  # Example:
  #   asia-southeast2-docker.pkg.dev/my-project/my-repo
  repository_url = "${var.location}-${local.repository_host_suffix}/${var.project_id}/${var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, var.repository_id]) : var.repository_id}"
}

resource "google_artifact_registry_repository" "this" {
  project       = var.project_id
  location      = var.location
  repository_id = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, var.repository_id]) : var.repository_id

  format = var.format
  mode   = var.mode

  description  = var.description
  kms_key_name = var.kms_key_name

  labels = local.repository_labels

  # ===== Docker-specific config =====
  dynamic "docker_config" {
    # Only create block if user explicitly sets it (not null)
    for_each = var.docker_immutable_tags == null ? [] : [1]
    content {
      immutable_tags = var.docker_immutable_tags
    }
  }

  # ===== Maven-specific config =====
  dynamic "maven_config" {
    # Render block hanya kalau format = MAVEN
    for_each = var.format == "MAVEN" ? [1] : []

    content {
      # Biar simple: biarin null kalau user nggak isi, provider akan handle
      allow_snapshot_overwrites = var.maven_allow_snapshot_overwrites
      version_policy            = var.maven_version_policy
    }
  }

  # ===== Cleanup policies & dry-run mode =====
  cleanup_policy_dry_run = var.cleanup_policy_dry_run

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      # Map key jadi ID policy → gampang di-refer
      id     = cleanup_policies.key
      action = cleanup_policies.value.action

      # Conditional keep/delete policy
      dynamic "condition" {
        for_each = cleanup_policies.value.condition == null ? [] : [cleanup_policies.value.condition]
        content {
          tag_state             = try(condition.value.tag_state, null)
          tag_prefixes          = try(condition.value.tag_prefixes, null)
          version_name_prefixes = try(condition.value.version_prefixes, null)
          package_name_prefixes = try(condition.value.package_name_prefixes, null)
          older_than            = try(condition.value.older_than, null)
          newer_than            = try(condition.value.newer_than, null)
        }
      }

      # “Keep most recent versions” policy
      dynamic "most_recent_versions" {
        for_each = cleanup_policies.value.most_recent_versions == null ? [] : [cleanup_policies.value.most_recent_versions]
        content {
          package_name_prefixes = try(most_recent_versions.value.package_name_prefixes, null)
          keep_count            = most_recent_versions.value.keep_count
        }
      }
    }
  }
}
