/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# ------------------------------------------------------------------------------
# 1. Foldering Hierarchy
# ------------------------------------------------------------------------------
resource "google_folder" "baseline" {
  display_name = "E2E-Baseline-Folder"
  parent       = var.organization_id
}

# ------------------------------------------------------------------------------
# 2. Project Creation & API Enablement
# ------------------------------------------------------------------------------
# Security Project for Governance
resource "google_project" "security_project" {
  name            = "e2e-security-governance"
  project_id      = "e2e-sec-gov-${formatdate("YYYYMMDD", timestamp())}"
  folder_id       = google_folder.baseline.name
  billing_account = var.billing_account

  labels = var.default_labels
}

# Audit Project for Central Logging
resource "google_project" "audit_project" {
  name            = "e2e-audit-logs"
  project_id      = "e2e-audit-${formatdate("YYYYMMDD", timestamp())}"
  folder_id       = google_folder.baseline.name
  billing_account = var.billing_account

  labels = var.default_labels
}

resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudasset.googleapis.com",
    "logging.googleapis.com"
  ])

  project = google_project.security_project.project_id
  service = each.key

  disable_on_destroy = false
}

# ------------------------------------------------------------------------------
# 3. Organization Policies, Contacts, Logging & Tags (via organization module)
# ------------------------------------------------------------------------------
module "org_setup" {
  source = "../../modules/organization"

  organization_id = var.organization_id

  # Essential Contacts
  contacts = {
    "noc@toylabs.com" = ["SECURITY", "TECHNICAL"]
  }

  # Hardened Org Policies
  org_policies = {
    "compute.disableGuestAttributesAccess" = {
      rules = [{ enforce = true }]
    }
    "compute.skipDefaultNetworkCreation" = {
      rules = [{ enforce = true }]
    }
    "iam.disableServiceAccountKeyCreation" = {
      rules = [{ enforce = true }]
    }
  }

  # Centralized Logging Sinks (Org-wide)
  logging_sinks = {
    "central-audit-log" = {
      type             = "project"
      destination      = google_project.audit_project.project_id
      filter           = "severity >= WARNING"
      include_children = true
    }
  }

  # Governance Tags
  tags = {
    "environment" = {
      description = "Deployment environment"
      values = {
        "production"  = { description = "Production resources" }
        "development" = { description = "Development/Sandbox" }
      }
    }
    "data-classification" = {
      description = "Sensitivity of data"
      values = {
        "public"       = { description = "Visible to anyone" }
        "confidential" = { description = "Internal only" }
      }
    }
  }
}

# ------------------------------------------------------------------------------
# 4. Hierarchical Firewall Policy (Org-level)
# ------------------------------------------------------------------------------
module "org_fw_policy" {
  source = "../../modules/net-firewall-policy"

  name      = "org-baseline-fw"
  parent_id = var.organization_id

  ingress_rules = {
    "allow-internal-hc" = {
      priority    = 1000
      action      = "allow"
      description = "Allow Google Cloud health checks"
      match = {
        source_ranges  = ["130.211.0.0/22", "35.191.0.0/16"]
        layer4_configs = [{ protocol = "tcp", ports = ["80", "443"] }]
      }
    }
    "deny-all-ingress" = {
      priority    = 65000
      action      = "deny"
      description = "Baseline deny for all other ingress"
      match = {
        source_ranges = ["0.0.0.0/0"]
      }
    }
  }
}

# Associate the policy to the Org
resource "google_compute_firewall_policy_association" "org_association" {
  attachment_target = var.organization_id
  name              = "baseline-fw-association"
  firewall_policy   = module.org_fw_policy.id
}
