# ============================================================================
# Plan Test: Windows first-class support
# ============================================================================
# Verifies that windows_startup_script / windows_shutdown_script are merged
# into the instance (and instance template) metadata under the Windows guest
# agent keys, and that enable_display is wired through.
# ============================================================================

mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id      = "win-dev-project"
  zone            = "asia-southeast2-a"
  resource_prefix = "dev-sap-win"
  join_separator  = "-"

  default_labels = {
    project = "sap"
    env     = "dev"
    owner   = "infra-team"
    os      = "windows"
  }

  data_compute_images = {
    win_2022 = {
      name    = "windows-server-2022-dc-v20240101"
      family  = "windows-2022"
      project = "windows-cloud"
    }
  }

  compute_disks = {
    boot = {
      name                           = "boot"
      description                    = "Boot disk for Windows SAP host."
      labels                         = {}
      size                           = 100
      physical_block_size_bytes      = null
      type                           = "pd-ssd"
      image                          = "win_2022"
      multi_writer                   = false
      provisioned_iops               = null
      zone                           = "asia-southeast2-a"
      project                        = null
      source_image_encryption_key    = null
      disk_encryption_key            = null
      source_snapshot_encryption_key = null
    }
  }

  compute_instance_templates = {}
  compute_resource_policies  = {}
  disk_snapshots             = []
  templatefiles              = {}
  tls_private_keys           = {}
}

run "plan_windows_instance" {
  command = plan

  variables {
    compute_instances = {
      win = {
        name         = "sap"
        machine_type = "n2-standard-4"
        zone         = "asia-southeast2-a"

        boot_disk = {
          auto_delete = true
          device_name = "boot"
          mode        = "READ_WRITE"
          source      = "boot"
        }

        network_interfaces = [
          {
            subnetwork         = "dev-sap-subnet"
            network_ip         = "10.20.0.10"
            subnetwork_project = null
            access_config      = null
          }
        ]

        allow_stopping_for_update = true
        attached_disk             = null
        can_ip_forward            = false
        description               = "Windows SAP host."
        deletion_protection       = false
        hostname                  = null
        labels                    = {}
        metadata                  = {}
        project                   = null

        scheduling = {
          preemptible         = false
          on_host_maintenance = "MIGRATE"
          automatic_restart   = true
          provisioning_model  = "STANDARD"
        }

        service_account = {
          email  = "default"
          scopes = ["https://www.googleapis.com/auth/cloud-platform"]
        }

        tags                     = []
        shielded_instance_config = null
        enable_display           = true
        resource_policies        = []

        windows_startup_script  = "Write-Host 'specialize: configuring SAP host'"
        windows_shutdown_script = "Write-Host 'shutdown: draining SAP services'"
      }
    }
  }

  # Startup script mapped to the sysprep-specialize key.
  assert {
    condition     = nonsensitive(output.compute_instances["win"].metadata["sysprep-specialize-script-ps1"]) == "Write-Host 'specialize: configuring SAP host'"
    error_message = "windows_startup_script must be merged into metadata as sysprep-specialize-script-ps1."
  }

  # Shutdown script mapped to the windows-shutdown key.
  assert {
    condition     = nonsensitive(output.compute_instances["win"].metadata["windows-shutdown-script-ps1"]) == "Write-Host 'shutdown: draining SAP services'"
    error_message = "windows_shutdown_script must be merged into metadata as windows-shutdown-script-ps1."
  }

  # Display device enabled for RDP/VNC.
  assert {
    condition     = nonsensitive(output.compute_instances["win"].enable_display) == true
    error_message = "enable_display must be wired through to the instance."
  }
}

run "plan_windows_instance_no_scripts" {
  command = plan

  variables {
    compute_instances = {
      lin = {
        name         = "app"
        machine_type = "e2-medium"
        zone         = "asia-southeast2-a"

        boot_disk = {
          auto_delete = true
          device_name = "boot"
          mode        = "READ_WRITE"
          source      = "boot"
        }

        network_interfaces = [
          {
            subnetwork         = "dev-sap-subnet"
            network_ip         = "10.20.0.20"
            subnetwork_project = null
            access_config      = null
          }
        ]

        allow_stopping_for_update = true
        attached_disk             = null
        can_ip_forward            = false
        description               = "Linux host, no Windows scripts."
        deletion_protection       = false
        hostname                  = null
        labels                    = {}
        metadata                  = {}
        project                   = null

        scheduling = {
          preemptible         = false
          on_host_maintenance = "MIGRATE"
          automatic_restart   = true
          provisioning_model  = "STANDARD"
        }

        service_account = {
          email  = "default"
          scopes = ["https://www.googleapis.com/auth/cloud-platform"]
        }

        tags                     = []
        shielded_instance_config = null
        enable_display           = false
        resource_policies        = []
      }
    }
  }

  # When no Windows scripts are provided, the keys must NOT be injected.
  assert {
    condition     = !contains(keys(nonsensitive(output.compute_instances["lin"].metadata)), "sysprep-specialize-script-ps1")
    error_message = "sysprep-specialize-script-ps1 must not be set when windows_startup_script is null."
  }

  assert {
    condition     = !contains(keys(nonsensitive(output.compute_instances["lin"].metadata)), "windows-shutdown-script-ps1")
    error_message = "windows-shutdown-script-ps1 must not be set when windows_shutdown_script is null."
  }
}
