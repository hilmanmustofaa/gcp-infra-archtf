run "plan_basic_zone" {
  command = plan

  variables {
    project_id = "test-project"

    dns_managed_zones = {
      public-zone = {
        name        = "example-com"
        dns_name    = "example.com."
        description = "Public zone for example.com"
        visibility  = "public"
        labels = {
          env = "prod"
        }
      }
    }

    default_labels = {
      managed_by = "terraform"
    }

    dns_record_sets = {
      www = {
        name         = "www"
        type         = "A"
        ttl          = 300
        managed_zone = "public-zone"
        rrdatas      = ["1.2.3.4"]
      }
    }
  }

  # Verify Managed Zone
  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["public-zone"].name == "example-com"
    error_message = "Zone name incorrect"
  }

  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["public-zone"].dns_name == "example.com."
    error_message = "DNS name incorrect"
  }

  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["public-zone"].visibility == "public"
    error_message = "Visibility incorrect"
  }

  # Verify Labels
  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["public-zone"].labels["env"] == "prod"
    error_message = "Should have user label env=prod"
  }

  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["public-zone"].labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  assert {
    condition     = google_dns_managed_zone.dns_managed_zones["public-zone"].labels["resourcetype"] == "dns-managed-zone"
    error_message = "Should have automatic label resourcetype=dns-managed-zone"
  }

  # Verify Record Set
  assert {
    condition     = google_dns_record_set.dns_record_sets["www"].name == "www.example.com."
    error_message = "Record name incorrect"
  }

  assert {
    condition     = google_dns_record_set.dns_record_sets["www"].type == "A"
    error_message = "Record type incorrect"
  }

  assert {
    condition     = google_dns_record_set.dns_record_sets["www"].rrdatas[0] == "1.2.3.4"
    error_message = "Record data incorrect"
  }
}
