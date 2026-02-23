run "plan_addresses" {
  command = plan

  variables {
    project_id = "test-project"

    external_addresses = {
      ext-1 = {
        name        = "external-ip-1"
        region      = "us-central1"
        description = "External IP for testing"
      }
    }

    internal_addresses = {
      int-1 = {
        name        = "internal-ip-1"
        region      = "us-central1"
        subnetwork  = "projects/test-project/regions/us-central1/subnetworks/subnet-1"
        description = "Internal IP for testing"
        address     = "10.0.0.5"
      }
    }

    global_addresses = {
      global-1 = {
        name        = "global-ip-1"
        description = "Global IP for testing"
        ip_version  = "IPV4"
      }
    }

    psa_addresses = {
      psa-1 = {
        name          = "psa-range"
        address       = "10.10.0.0"
        prefix_length = 16
        network       = "projects/test-project/global/networks/vpc-1"
      }
    }
  }

  # Verify External Address
  assert {
    condition     = output.external_addresses["external-ip-1"].address_type == "EXTERNAL"
    error_message = "External Address type should be EXTERNAL"
  }

  assert {
    condition     = output.external_addresses["external-ip-1"].region == "us-central1"
    error_message = "External Address region should be us-central1"
  }

  # Verify Internal Address
  assert {
    condition     = output.internal_addresses["internal-ip-1"].address_type == "INTERNAL"
    error_message = "Internal Address type should be INTERNAL"
  }

  assert {
    condition     = output.internal_addresses["internal-ip-1"].address == "10.0.0.5"
    error_message = "Internal Address IP should be 10.0.0.5"
  }

  # Verify Global Address
  assert {
    condition     = output.global_addresses["global-ip-1"].name == "global-ip-1"
    error_message = "Global Address name should be global-ip-1"
  }

  # Verify PSA Address
  assert {
    condition     = output.psa_addresses["psa-range"].prefix_length == 16
    error_message = "PSA Address prefix length should be 16"
  }
}
