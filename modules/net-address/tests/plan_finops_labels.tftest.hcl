run "plan_finops_labels" {
  command = plan

  variables {
    project_id = "test-project"

    default_labels = {
      environment = "dev"
      team        = "network"
    }

    external_addresses = {
      ext-1 = {
        name   = "external-ip-1"
        region = "us-central1"
        labels = {
          cost-center = "1234"
        }
      }
    }

    internal_addresses = {
      int-1 = {
        name       = "internal-ip-1"
        region     = "us-central1"
        subnetwork = "projects/test-project/regions/us-central1/subnetworks/subnet-1"
        labels = {
          application = "app1"
        }
      }
    }

    global_addresses = {
      global-1 = {
        name = "global-ip-1"
        labels = {
          service = "lb"
        }
      }
    }
  }

  # Verify External Address labels
  assert {
    condition     = output.external_addresses["external-ip-1"].labels["environment"] == "dev"
    error_message = "External Address should have default label environment=dev"
  }

  assert {
    condition     = output.external_addresses["external-ip-1"].labels["cost-center"] == "1234"
    error_message = "External Address should have specific label cost-center=1234"
  }

  # Verify Internal Address labels
  assert {
    condition     = output.internal_addresses["internal-ip-1"].labels["team"] == "network"
    error_message = "Internal Address should have default label team=network"
  }

  assert {
    condition     = output.internal_addresses["internal-ip-1"].labels["application"] == "app1"
    error_message = "Internal Address should have specific label application=app1"
  }

  # Verify Global Address labels
  assert {
    condition     = output.global_addresses["global-ip-1"].labels["environment"] == "dev"
    error_message = "Global Address should have default label environment=dev"
  }

  assert {
    condition     = output.global_addresses["global-ip-1"].labels["service"] == "lb"
    error_message = "Global Address should have specific label service=lb"
  }
}
