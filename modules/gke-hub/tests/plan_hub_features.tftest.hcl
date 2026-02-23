run "plan_hub_features" {
  command = plan

  variables {
    project_id = "test-project"

    clusters = {
      cluster-1 = "projects/test-project/locations/us-central1/clusters/cluster-1"
    }

    default_labels = {
      environment = "production"
      team        = "platform"
    }

    features = {
      servicemesh                  = true
      multiclusterservicediscovery = true
    }
  }

  # Verify Features
  assert {
    condition     = length(google_gke_hub_feature.default) == 2
    error_message = "Should have 2 hub features enabled"
  }

  assert {
    condition     = google_gke_hub_feature.default["servicemesh"].name == "servicemesh"
    error_message = "Service mesh feature name incorrect"
  }

  # Verify Feature Labels
  assert {
    condition     = google_gke_hub_feature.default["servicemesh"].labels["environment"] == "production"
    error_message = "Should have default label environment=production"
  }

  assert {
    condition     = google_gke_hub_feature.default["servicemesh"].labels["team"] == "platform"
    error_message = "Should have default label team=platform"
  }

  assert {
    condition     = google_gke_hub_feature.default["servicemesh"].labels["resourcetype"] == "gke-hub-feature"
    error_message = "Should have automatic label resourcetype=gke-hub-feature"
  }

  assert {
    condition     = google_gke_hub_feature.default["servicemesh"].labels["feature"] == "servicemesh"
    error_message = "Should have automatic label feature=servicemesh"
  }

  # Verify Service Mesh Membership
  assert {
    condition     = length(google_gke_hub_feature_membership.servicemesh) == 1
    error_message = "Should have 1 service mesh membership"
  }
}
