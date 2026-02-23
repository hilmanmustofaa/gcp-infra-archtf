run "plan_regional" {
  command = plan

  variables {
    name      = "regional-policy"
    parent_id = "test-project"
    region    = "us-central1"

    ingress_rules = {
      allow-http = {
        priority = 1000
        action   = "allow"
        match = {
          layer4_configs = [{
            protocol = "tcp"
            ports    = ["80"]
          }]
          source_ranges = ["0.0.0.0/0"]
        }
      }
    }
  }

  assert {
    condition     = google_compute_region_network_firewall_policy.net-regional[0].name == "regional-policy"
    error_message = "Regional policy name should be regional-policy"
  }

  assert {
    condition     = google_compute_region_network_firewall_policy.net-regional[0].region == "us-central1"
    error_message = "Regional policy region should be us-central1"
  }
}
