# ============================================================================
# Plan Test: IAP tunnel instance IAM (SSH/RDP to VMs)
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

run "plan_tunnel" {
  command = plan

  variables {
    tunnel_instance_bindings = {
      bastion = {
        zone     = "asia-southeast2-a"
        instance = "bastion-host"
        members  = ["group:sre@example.com"]
      }
    }
    tunnel_instance_members = {
      breakglass = {
        zone     = "asia-southeast2-a"
        instance = "bastion-host"
        member   = "user:oncall@example.com"
      }
    }
  }

  # Default tunnel role applied.
  assert {
    condition     = google_iap_tunnel_instance_iam_binding.tunnel_bindings["bastion"].role == "roles/iap.tunnelResourceAccessor"
    error_message = "Tunnel binding must default to roles/iap.tunnelResourceAccessor."
  }

  assert {
    condition     = google_iap_tunnel_instance_iam_binding.tunnel_bindings["bastion"].instance == "bastion-host"
    error_message = "Tunnel binding must target the configured instance."
  }

  assert {
    condition     = google_iap_tunnel_instance_iam_member.tunnel_members["breakglass"].member == "user:oncall@example.com"
    error_message = "Additive tunnel member must be wired."
  }
}
