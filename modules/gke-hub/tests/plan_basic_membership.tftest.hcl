run "plan_basic_membership" {
  command = plan

  variables {
    project_id = "test-project"

    clusters = {
      cluster-1 = "projects/test-project/locations/us-central1/clusters/cluster-1"
      cluster-2 = "projects/test-project/locations/us-east1/clusters/cluster-2"
    }

    default_labels = {
      environment = "test"
      managed_by  = "terraform"
    }

    features = {
      servicemesh = false
    }
  }

  # Verify Memberships
  assert {
    condition     = length(google_gke_hub_membership.default) == 2
    error_message = "Should have 2 hub memberships"
  }

  assert {
    condition     = google_gke_hub_membership.default["cluster-1"].membership_id == "cluster-1"
    error_message = "Membership ID incorrect for cluster-1"
  }

  # Verify Labels
  assert {
    condition     = google_gke_hub_membership.default["cluster-1"].labels["environment"] == "test"
    error_message = "Should have default label environment=test"
  }

  assert {
    condition     = google_gke_hub_membership.default["cluster-1"].labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  assert {
    condition     = google_gke_hub_membership.default["cluster-1"].labels["resourcetype"] == "gke-hub-membership"
    error_message = "Should have automatic label resourcetype=gke-hub-membership"
  }
}
