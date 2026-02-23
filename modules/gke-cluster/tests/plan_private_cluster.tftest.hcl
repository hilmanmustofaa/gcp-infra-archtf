run "plan_private_cluster" {
  command = plan

  variables {
    name       = "private-cluster"
    project_id = "test-project"
    location   = "us-central1"

    network    = "projects/test-project/global/networks/vpc-1"
    subnetwork = "projects/test-project/regions/us-central1/subnetworks/subnet-1"

    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"

    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"

    # Hardened: mandatory KMS encryption
    database_encryption = {
      state    = "ENCRYPTED"
      key_name = "projects/test-project/locations/us-central1/keyRings/gke-ring/cryptoKeys/gke-key"
    }

    # Hardened: mandatory custom service account
    node_service_account = "gke-nodes@test-project.iam.gserviceaccount.com"

    # FinOps: mandatory labels
    default_labels = {
      env     = "production"
      project = "secure-platform"
      owner   = "security-team"
    }

    enable_addons = {
      horizontal_pod_autoscaling = true
      http_load_balancing        = true
      network_policy             = false
      cloudrun                   = false
    }

    master_authorized_networks = [
      {
        cidr_block   = "10.0.0.0/8"
        display_name = "internal-network"
      }
    ]

    node_locations = []
  }

  # Verify Cluster
  assert {
    condition     = google_container_cluster.container_clusters.name == "private-cluster"
    error_message = "Cluster name incorrect"
  }

  # Verify Private Configuration
  assert {
    condition     = google_container_cluster.container_clusters.private_cluster_config[0].enable_private_nodes == true
    error_message = "Private nodes should be enabled"
  }

  assert {
    condition     = google_container_cluster.container_clusters.private_cluster_config[0].enable_private_endpoint == true
    error_message = "Private endpoint should be enabled"
  }

  # Verify Master Authorized Networks
  assert {
    condition     = length(google_container_cluster.container_clusters.master_authorized_networks_config[0].cidr_blocks) == 1
    error_message = "Should have 1 authorized network"
  }

  # Verify KMS Encryption
  assert {
    condition     = google_container_cluster.container_clusters.database_encryption[0].state == "ENCRYPTED"
    error_message = "Database encryption should be ENCRYPTED"
  }
}
