run "plan_basic_router" {
  command = plan

  variables {
    resource_prefix = "test"

    compute_routers = {
      router-1 = {
        name                          = "router-1"
        network                       = "projects/test-project/global/networks/vpc-1"
        region                        = "us-central1"
        project                       = "test-project"
        description                   = "Test router 1"
        encrypted_interconnect_router = false
        bgp                           = null
      }
      router-2 = {
        name                          = "router-2"
        network                       = "projects/test-project/global/networks/vpc-2"
        region                        = "us-east1"
        project                       = "test-project"
        description                   = "Test router 2"
        encrypted_interconnect_router = false
        bgp                           = null
      }
    }
  }

  # Verify Router 1
  assert {
    condition     = google_compute_router.compute_routers["router-1"].name == "test-router-1"
    error_message = "Router 1 name incorrect"
  }

  assert {
    condition     = google_compute_router.compute_routers["router-1"].region == "us-central1"
    error_message = "Router 1 region incorrect"
  }

  # Verify Router 2
  assert {
    condition     = google_compute_router.compute_routers["router-2"].name == "test-router-2"
    error_message = "Router 2 name incorrect"
  }

  assert {
    condition     = google_compute_router.compute_routers["router-2"].region == "us-east1"
    error_message = "Router 2 region incorrect"
  }
}
