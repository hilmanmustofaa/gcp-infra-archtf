run "plan_autopilot_cluster" {
  command = plan

  variables {
    name       = "autopilot-cluster"
    project_id = "test-project"
    location   = "us-central1"

    network    = "projects/test-project/global/networks/vpc-1"
    subnetwork = "projects/test-project/regions/us-central1/subnetworks/subnet-1"

    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"

    default_labels = {
      environment = "production"
      managed_by  = "terraform"
    }
  }

  # Verify Cluster
  assert {
    condition     = google_container_cluster.autopilot_cluster.name == "autopilot-cluster"
    error_message = "Cluster name incorrect"
  }

  assert {
    condition     = google_container_cluster.autopilot_cluster.enable_autopilot == true
    error_message = "Autopilot should be enabled"
  }

  # Verify Labels
  assert {
    condition     = google_container_cluster.autopilot_cluster.resource_labels["environment"] == "production"
    error_message = "Should have default label environment=production"
  }

  assert {
    condition     = google_container_cluster.autopilot_cluster.resource_labels["resourcetype"] == "gke-autopilot-cluster"
    error_message = "Should have automatic label resourcetype=gke-autopilot-cluster"
  }
}
