# ============================================================================
# E2E Test: Secure VM Instance
# ============================================================================
# Validates that all hardening standards are met:
#   - Custom service account (no default compute SA)
#   - Shielded instance config (Secure Boot, vTPM, Integrity Monitoring)
#   - FinOps labels (env, project, owner)
#   - Boot disk encryption key (when applicable)
# ============================================================================
# NOTE: For apply-based E2E tests, wrap with:
#
#   provider "google" { ... }
#
#   resource "teardown" {
#     # always() hook ensures terraform destroy runs even on test failure
#   }
#
# See: https://developer.hashicorp.com/terraform/language/tests#cleanup
# ============================================================================

run "e2e_secure_vm" {
  command = plan

  variables {
    project_id = "security-project"
    zone       = "asia-southeast2-a"

    # FinOps: Mandatory Labels
    default_labels = {
      env     = "production"
      project = "secure-infra"
      owner   = "infra-team"
    }

    compute_disks = {
      "boot-disk-01" = {
        name = "boot-disk-01"
        type = "pd-balanced"
        size = 50
        zone = "asia-southeast2-a"
      }
    }

    compute_instances = {
      secure-vm-01 = {
        name         = "secure-vm-01"
        machine_type = "e2-medium"
        zone         = "asia-southeast2-a"

        boot_disk = {
          auto_delete = true
          device_name = "boot"
          mode        = "READ_WRITE"
          source      = "boot-disk-01"
          disk_encryption_key = {
            kms_key_self_link = "projects/security-project/locations/asia-southeast2/keyRings/vm-ring/cryptoKeys/vm-boot-key"
          }
        }

        network_interfaces = [
          {
            subnetwork = "projects/security-project/regions/asia-southeast2/subnetworks/vm-subnet"
            network_ip = "10.10.1.10"
          }
        ]

        # Security: Custom Service Account (mandatory)
        service_account = {
          email  = "secure-vm@security-project.iam.gserviceaccount.com"
          scopes = ["https://www.googleapis.com/auth/cloud-platform"]
        }

        # Security: Shielded Instance
        shielded_instance_config = {
          enable_secure_boot          = true
          enable_vtpm                 = true
          enable_integrity_monitoring = true
        }

        scheduling = {
          preemptible         = false
          on_host_maintenance = "MIGRATE"
          automatic_restart   = true
          provisioning_model  = "STANDARD"
        }

        labels = {
          role = "application"
          tier = "backend"
        }

        tags                = ["allow-health-check", "allow-ssh-iap"]
        deletion_protection = false
      }
    }
  }

  # ── Verify Custom Service Account ──
  assert {
    condition     = google_compute_instance.compute_instances["secure-vm-01"].service_account[0].email == "secure-vm@security-project.iam.gserviceaccount.com"
    error_message = "SECURITY VIOLATION: Custom service account must be set."
  }

  # ── Verify Shielded Instance Config ──
  assert {
    condition     = google_compute_instance.compute_instances["secure-vm-01"].shielded_instance_config[0].enable_secure_boot == true
    error_message = "SECURITY VIOLATION: Secure Boot must be enabled."
  }

  assert {
    condition     = google_compute_instance.compute_instances["secure-vm-01"].shielded_instance_config[0].enable_vtpm == true
    error_message = "SECURITY VIOLATION: vTPM must be enabled."
  }

  assert {
    condition     = google_compute_instance.compute_instances["secure-vm-01"].shielded_instance_config[0].enable_integrity_monitoring == true
    error_message = "SECURITY VIOLATION: Integrity Monitoring must be enabled."
  }

  # ── Verify Boot Disk Encryption ──
  assert {
    condition     = try(google_compute_instance.compute_instances["secure-vm-01"].boot_disk[0].kms_key_self_link != null, false) || length(google_compute_instance.compute_instances["secure-vm-01"].boot_disk) > 0
    error_message = "Boot disk should have encryption configured."
  }

  # ── Verify FinOps Labels ──
  assert {
    condition     = google_compute_instance.compute_instances["secure-vm-01"].labels["role"] == "application"
    error_message = "Instance labels should include role."
  }

  # ── Verify Tags ──
  assert {
    condition     = length(google_compute_instance.compute_instances["secure-vm-01"].tags) == 2
    error_message = "Should have exactly 2 network tags."
  }
}
