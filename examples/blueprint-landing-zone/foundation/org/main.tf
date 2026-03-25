/**
 * # Landing Zone - Layer 01: Organization Foundation
 *
 * This layer establishes the folder hierarchy, governance projects, 
 * and organization policies.
 */

# 1. Folders
resource "google_folder" "common" {
  display_name = "Common"
  parent       = var.organization_id
}

resource "google_folder" "production" {
  display_name = "Production"
  parent       = var.organization_id
}

resource "google_folder" "development" {
  display_name = "Development"
  parent       = var.organization_id
}

# 2. Governance Projects
resource "google_project" "audit" {
  name            = "org-audit-logging"
  project_id      = "org-audit-${formatdate("YYYYMMDD", timestamp())}"
  folder_id       = google_folder.common.name
  billing_account = var.billing_account
  labels          = var.default_labels
}

# 3. Organization Policies & Baseline
module "org_policies" {
  source = "../../../../modules/organization"

  organization_id = var.organization_id

  org_policies = {
    "compute.disableGuestAttributesAccess" = { rules = [{ enforce = true }] }
    "compute.skipDefaultNetworkCreation"   = { rules = [{ enforce = true }] }
    "iam.disableServiceAccountKeyCreation" = { rules = [{ enforce = true }] }
    "storage.uniformBucketLevelAccess"     = { rules = [{ enforce = true }] }
  }

  logging_sinks = {
    "org-audit-sink" = {
      type             = "project"
      destination      = google_project.audit.project_id
      filter           = "severity >= NOTICE"
      include_children = true
    }
  }
}

# Outputs for next layers
output "folder_ids" {
  value = {
    common = google_folder.common.name
    prod   = google_folder.production.name
    dev    = google_folder.development.name
  }
}

output "audit_project_id" {
  value = google_project.audit.project_id
}
