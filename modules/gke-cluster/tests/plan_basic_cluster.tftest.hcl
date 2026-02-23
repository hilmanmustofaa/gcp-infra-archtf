run "plan_basic_cluster" {
  command = plan

  variables {
    name       = "test-cluster"
    project_id = "test-project"
    location   = "us-central1"

    network    = "projects/test-project/global/networks/vpc-1"
    subnetwork = "projects/test-project/regions/us-central1/subnetworks/subnet-1"

    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"

    enable_private_nodes    = false
    enable_private_endpoint = false

    # Hardened: mandatory KMS encryption
    database_encryption = {
      state    = "ENCRYPTED"
      key_name = "projects/test-project/locations/us-central1/keyRings/gke-ring/cryptoKeys/gke-key"
    }

    # Hardened: mandatory custom service account
    node_service_account = "gke-nodes@test-project.iam.gserviceaccount.com"

    # FinOps: mandatory labels
    default_labels = {
      env     = "dev"
      project = "test-project"
      owner   = "platform-team"
    }

    enable_addons = {
      horizontal_pod_autoscaling = true
      http_load_balancing        = true
      network_policy             = false
      cloudrun                   = false
    }

    node_locations = ["us-central1-a", "us-central1-b"]
  }

  # Verify Cluster
  assert {
    condition     = google_container_cluster.container_clusters.name == "test-cluster"
    error_message = "Cluster name incorrect"
  }

  assert {
    condition     = google_container_cluster.container_clusters.location == "us-central1"
    error_message = "Cluster location incorrect"
  }

  # Verify Network Configuration
  assert {
    condition     = google_container_cluster.container_clusters.network == "projects/test-project/global/networks/vpc-1"
    error_message = "Network incorrect"
  }

  # Verify Node Locations
  assert {
    condition     = length(google_container_cluster.container_clusters.node_locations) == 2
    error_message = "Should have 2 node locations"
  }
}
