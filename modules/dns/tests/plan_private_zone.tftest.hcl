run "plan_private_zone" {
  command = plan

  variables {
    project_id = "test-project"

    network_lookup = {
      vpc-1 = {
        self_link = "projects/test-project/global/networks/vpc-1"
      }
    }

    dns_managed_zones = {
      private-zone = {
        name        = "internal-com"
        dns_name    = "internal.com."
        description = "Private zone for internal.com"
        visibility  = "private"

        private_visibility_config = {
          networks = ["vpc-1"]
        }

        labels = {
          env = "dev"
        }
      }
    }

    default_labels = {
      managed_by = "terraform"
    }
  }

  # Verify Managed Zone
  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["private-zone"].name == "internal-com"
    error_message = "Zone name incorrect"
  }

  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["private-zone"].visibility == "private"
    error_message = "Visibility incorrect"
  }

  # Verify Private Visibility
  assert {
    condition     = one(google_dns_managed_zone.dns_managed_zones["private-zone"].private_visibility_config[0].networks).network_url == "projects/test-project/global/networks/vpc-1"
    error_message = "Network URL incorrect"
  }

  # Verify Labels
  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["private-zone"].labels["env"] == "dev"
    error_message = "Should have user label env=dev"
  }

  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["private-zone"].labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["private-zone"].labels["resourcetype"] == "dns-managed-zone"
    error_message = "Should have automatic label resourcetype=dns-managed-zone"
  }
}
