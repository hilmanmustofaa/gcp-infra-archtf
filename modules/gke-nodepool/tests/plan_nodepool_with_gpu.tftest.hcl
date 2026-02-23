run "plan_nodepool_with_gpu" {
  command = plan

  variables {
    project_id   = "test-project"
    cluster_name = "test-cluster"
    location     = "us-central1"
    name         = "gpu-pool"

    machine_type = "n1-standard-4"

    node_count = {
      initial = 0
      current = 1
    }

    autoscaling = {
      min_node_count = 0
      max_node_count = 3
    }

    guest_accelerator = {
      type  = "nvidia-tesla-t4"
      count = 1
      gpu_driver = {
        version = "DEFAULT"
      }
    }

    service_account_email = "test-sa@test-project.iam.gserviceaccount.com"

    default_labels = {
      environment = "production"
      team        = "ml"
    }

    labels = {
      workload = "gpu"
      gpu_type = "t4"
    }
  }

  # Verify Node Pool
  assert {
    condition     = google_container_node_pool.container_node_pools.name == "gpu-pool"
    error_message = "Node pool name incorrect"
  }

  # Verify GPU Configuration
  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].guest_accelerator[0].type == "nvidia-tesla-t4"
    error_message = "GPU type incorrect"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].guest_accelerator[0].count == 1
    error_message = "GPU count incorrect"
  }

  # Verify Labels
  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["environment"] == "production"
    error_message = "Should have default label environment=production"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["team"] == "ml"
    error_message = "Should have default label team=ml"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["workload"] == "gpu"
    error_message = "Should have user label workload=gpu"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["gpu_type"] == "t4"
    error_message = "Should have user label gpu_type=t4"
  }

  assert {
    condition     = google_container_node_pool.container_node_pools.node_config[0].labels["resourcetype"] == "gke-nodepool"
    error_message = "Should have automatic label resourcetype=gke-nodepool"
  }
}
