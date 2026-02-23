# ============================================================================
# E2E Test: Hardened GKE Cluster
# ============================================================================
# Validates that all hardening standards are met:
#   - Cloud KMS database encryption (ENCRYPTED state)
#   - Custom service account (no default compute SA)
#   - Workload Identity enabled
#   - Private nodes + authorized networks
#   - Shielded nodes enabled
#   - FinOps labels (env, project, owner)
# ============================================================================

run "e2e_hardened_gke" {
  command = plan

  variables {
    name       = "hardened-cluster"
    project_id = "security-project"
    location   = "asia-southeast2"

    network    = "projects/security-project/global/networks/prod-vpc"
    subnetwork = "projects/security-project/regions/asia-southeast2/subnetworks/gke-subnet"

    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"

    # ── Security: KMS Encryption (mandatory) ──
    database_encryption = {
      state    = "ENCRYPTED"
      key_name = "projects/security-project/locations/asia-southeast2/keyRings/gke-ring/cryptoKeys/gke-secrets-key"
    }

    # ── Security: Custom Service Account (mandatory) ──
    node_service_account = "gke-hardened-nodes@security-project.iam.gserviceaccount.com"

    # ── Security: Workload Identity ──
    workload_pool = "security-project.svc.id.goog"

    # ── Security: Private Cluster ──
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
    enable_shielded_nodes   = true

    master_authorized_networks = [
      {
        cidr_block   = "10.0.0.0/8"
        display_name = "internal-only"
      }
    ]

    # ── FinOps: Mandatory Labels ──
    default_labels = {
      env         = "production"
      project     = "security-platform"
      owner       = "security-team"
      cost_center = "cc-infra-001"
    }

    enable_addons = {
      horizontal_pod_autoscaling = true
      http_load_balancing        = true
      network_policy             = true
      cloudrun                   = false
    }

    node_locations = ["asia-southeast2-a", "asia-southeast2-b"]
  }

  # ── Verify KMS Encryption ──
  assert {
    condition     = google_container_cluster.container_clusters.database_encryption[0].state == "ENCRYPTED"
    error_message = "SECURITY VIOLATION: Database encryption must be ENCRYPTED."
  }

  assert {
    condition     = length(google_container_cluster.container_clusters.database_encryption[0].key_name) > 0
    error_message = "SECURITY VIOLATION: KMS key_name must be provided."
  }

  # ── Verify Custom Service Account ──
  assert {
    condition     = google_container_cluster.container_clusters.node_config[0].service_account == "gke-hardened-nodes@security-project.iam.gserviceaccount.com"
    error_message = "SECURITY VIOLATION: Custom service account must be set."
  }

  # ── Verify Workload Identity ──
  assert {
    condition     = length(google_container_cluster.container_clusters.workload_identity_config) > 0
    error_message = "SECURITY VIOLATION: Workload Identity must be enabled."
  }

  # ── Verify Private Cluster ──
  assert {
    condition     = google_container_cluster.container_clusters.private_cluster_config[0].enable_private_nodes == true
    error_message = "SECURITY VIOLATION: Private nodes must be enabled."
  }

  assert {
    condition     = google_container_cluster.container_clusters.private_cluster_config[0].enable_private_endpoint == true
    error_message = "SECURITY VIOLATION: Private endpoint must be enabled."
  }

  # ── Verify Shielded Nodes ──
  assert {
    condition     = google_container_cluster.container_clusters.enable_shielded_nodes == true
    error_message = "SECURITY VIOLATION: Shielded nodes must be enabled."
  }

  # ── Verify FinOps Labels ──
  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["env"] == "production"
    error_message = "FINOPS VIOLATION: Label 'env' must be set."
  }

  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["project"] == "security-platform"
    error_message = "FINOPS VIOLATION: Label 'project' must be set."
  }

  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["owner"] == "security-team"
    error_message = "FINOPS VIOLATION: Label 'owner' must be set."
  }

  # ── Verify Network Policy ──
  assert {
    condition     = google_container_cluster.container_clusters.network_policy[0].enabled == true
    error_message = "Network policy should be enabled for hardened clusters."
  }
}
