run "plan_basic_nodepool" {
  command = plan

  variables {
    project_id   = "test-project"
    cluster_name = "test-cluster"
    location     = "us-central1"
    name         = "default-pool"

    machine_type = "e2-medium"

    node_count = {
      initial = 1
      current = 3
    }

    autoscaling = {
      min_node_count = 1
      max_node_count = 5
    }

    service_account_email = "test-sa@test-project.iam.gserviceaccount.com"

    default_labels = {
      environment = "test"
      managed_by  = "terraform"
    }

    labels = {
      workload = "general"
    }
  }

  # Verify Node Pool
  assert {
    condition     = google_container_node_pool.container_node_pools.name == "default-pool"
    error_message = "Node pool name incorrect"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.initial_node_count == 1
    error_message = "Initial node count incorrect"
  }

  # Verify Autoscaling
  assert {
    condition     = google_container_node_pool.container_node_pools.autoscaling[0].min_node_count == 1
    error_message = "Min node count incorrect"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.autoscaling[0].max_node_count == 5
    error_message = "Max node count incorrect"
  }

  # Verify Labels
  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["environment"] == "test"
    error_message = "Should have default label environment=test"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["workload"] == "general"
    error_message = "Should have user label workload=general"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["resourcetype"] == "gke-nodepool"
    error_message = "Should have automatic label resourcetype=gke-nodepool"
  }
}
