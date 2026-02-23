run "plan_finops_labels" {
  command = plan

  variables {
    name       = "labeled-cluster"
    project_id = "test-project"
    location   = "us-central1"

    network    = "projects/test-project/global/networks/vpc-1"
    subnetwork = "projects/test-project/regions/us-central1/subnetworks/subnet-1"

    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"

    # Hardened: mandatory KMS encryption
    database_encryption = {
      state    = "ENCRYPTED"
      key_name = "projects/test-project/locations/us-central1/keyRings/gke-ring/cryptoKeys/gke-key"
    }

    # Hardened: mandatory custom service account
    node_service_account = "gke-nodes@test-project.iam.gserviceaccount.com"

    # FinOps: mandatory labels with additional custom labels
    default_labels = {
      env        = "production"
      project    = "platform-core"
      owner      = "platform-team"
      managed_by = "terraform"
      team       = "platform"
    }

    enable_addons = {
      horizontal_pod_autoscaling = true
      http_load_balancing        = true
      network_policy             = false
      cloudrun                   = false
    }

    node_locations = []
  }

  # Verify FinOps Labels (mandatory)
  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["env"] == "production"
    error_message = "Should have FinOps label env=production"
  }

  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["project"] == "platform-core"
    error_message = "Should have FinOps label project=platform-core"
  }

  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["owner"] == "platform-team"
    error_message = "Should have FinOps label owner=platform-team"
  }

  # Verify Custom Labels
  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["team"] == "platform"
    error_message = "Should have default label team=platform"
  }

  # Verify Automatic Labels
  assert {
    condition     = google_container_cluster.container_clusters.resource_labels["resourcetype"] == "gke-cluster"
    error_message = "Should have automatic label resourcetype=gke-cluster"
  }
}
