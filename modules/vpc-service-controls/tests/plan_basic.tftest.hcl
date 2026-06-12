mock_provider "google" {}

variables {
  access_policy_id = "accessPolicies/123456789"
  default_labels = {
    env     = "test"
    project = "demo"
    owner   = "platform"
  }
}

run "plan_basic" {
  command = plan

  variables {
    access_levels = {
      corp = {
        title = "Corp network"
        conditions = [
          {
            ip_subnetworks = ["203.0.113.0/24"]
            regions        = ["ID"]
          }
        ]
      }
    }
    service_perimeters = {
      data = {
        title               = "Data perimeter"
        resources           = ["projects/123456789"]
        restricted_services = ["bigquery.googleapis.com", "storage.googleapis.com"]
        access_levels       = ["corp"] # logical key resolves to full name
        vpc_accessible_services = {
          enable_restriction = true
          allowed_services   = ["bigquery.googleapis.com"]
        }
      }
    }
  }

  assert {
    condition     = google_access_context_manager_access_level.levels["corp"].name == "accessPolicies/123456789/accessLevels/corp"
    error_message = "Access level name must be the full policy-scoped resource name."
  }

  assert {
    condition     = contains(google_access_context_manager_service_perimeter.perimeters["data"].status[0].access_levels, "accessPolicies/123456789/accessLevels/corp")
    error_message = "Perimeter must resolve the access-level logical key to its full name."
  }

  assert {
    condition     = contains(google_access_context_manager_service_perimeter.perimeters["data"].status[0].restricted_services, "bigquery.googleapis.com")
    error_message = "Restricted services must be wired into the perimeter status."
  }
}

run "plan_with_ingress_egress" {
  command = plan

  variables {
    service_perimeters = {
      locked = {
        title               = "Locked perimeter"
        resources           = ["projects/123456789"]
        restricted_services = ["storage.googleapis.com"]
        ingress_policies = [
          {
            from = {
              identity_type = "ANY_IDENTITY"
              sources       = [{ resource = "projects/987654321" }]
            }
            to = {
              resources  = ["*"]
              operations = [{ service_name = "storage.googleapis.com", methods = ["google.storage.objects.get"] }]
            }
          }
        ]
        egress_policies = [
          {
            from = { identity_type = "ANY_SERVICE_ACCOUNT" }
            to = {
              resources  = ["projects/555555555"]
              operations = [{ service_name = "*" }]
            }
          }
        ]
      }
    }
  }

  assert {
    condition     = google_access_context_manager_service_perimeter.perimeters["locked"].status[0].ingress_policies[0].ingress_to[0].operations[0].service_name == "storage.googleapis.com"
    error_message = "Ingress operation service_name must be wired."
  }

  assert {
    condition     = google_access_context_manager_service_perimeter.perimeters["locked"].status[0].egress_policies[0].egress_from[0].identity_type == "ANY_SERVICE_ACCOUNT"
    error_message = "Egress identity_type must be wired."
  }
}
