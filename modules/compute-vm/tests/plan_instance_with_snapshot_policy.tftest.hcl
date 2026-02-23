mock_provider "google" {}
mock_provider "google-beta" {}

run "plan_instance_with_snapshot_policy" {
  command = plan

  variables {
    project_id      = "joey-uat-project"
    zone            = "asia-southeast2-a"
    resource_prefix = "uat-aml-web"
    join_separator  = "-"

    default_labels = {
      project     = "aml"
      env         = "uat"
      product     = "aml"
      owner       = "devops-team"
      cost_center = "CC-002"
      managed_by  = "terraform"
      module      = "compute-vm"
    }

    data_compute_images = {
      debian_12 = {
        name    = "debian-12"
        family  = "debian-12"
        project = "debian-cloud"
      }
    }

    compute_disks = {
      boot = {
        name                           = "boot"
        description                    = "Boot disk for AML web (UAT)."
        labels                         = {}
        size                           = 50
        physical_block_size_bytes      = null
        type                           = "pd-balanced"
        image                          = "debian_12"
        multi_writer                   = false
        provisioned_iops               = null
        zone                           = "asia-southeast2-a"
        project                        = null
        source_image_encryption_key    = null
        disk_encryption_key            = null
        source_snapshot_encryption_key = null
      }
    }

    compute_instances = {
      vm1 = {
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
            subnetwork         = "uat-aml-subnet"
            network_ip         = "10.20.0.10"
            subnetwork_project = null
            access_config = {
              nat_ip       = null
              network_tier = "PREMIUM"
            }
          }
        ]

        allow_stopping_for_update = true
        attached_disk             = null
        can_ip_forward            = false
        description               = "UAT AML web instance."
        deletion_protection       = false
        hostname                  = null
        labels                    = {}
        metadata = {
          "ssh-keys" = "joey:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDj"
        }
        project = null

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
        resource_policies        = ["snapshot-policy-1"]
      }
    }

    compute_instance_templates = {}

    compute_resource_policies = {
      snapshot_policy_1 = {
        name        = "snapshot-policy-1"
        description = "Daily snapshot policy for AML UAT disks."

        snapshot_schedule_policy = {
          daily_schedule = {
            days_in_cycle = 1
            start_time    = "03:00"
          }

          retention_policy = {
            max_retention_days    = 7
            on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
          }

          snapshot_properties = {
            guest_flush       = false
            labels            = {}
            storage_locations = ["asia-southeast2"]
          }
        }

        region  = "asia-southeast2"
        project = null
      }
    }

    disk_snapshots = []

    templatefiles = {}

    tls_private_keys = {
      default = {
        algorithm   = "RSA"
        rsa_bits    = 4096
        ecdsa_curve = null
      }
    }
  }

  # === ASSERTIONS ===

  # 1) 1 disk, 1 instance, 1 resource policy
  assert {
    condition = (
      length(output.compute_disks) == 1 &&
      length(output.compute_instances) == 1 &&
      length(output.resource_policies) == 1
    )
    error_message = "Expected 1 disk, 1 instance, and 1 snapshot resource policy."
  }

  # 2) env label = uat di disk & instance
  assert {
    condition = alltrue([
      for d in values(output.compute_disks) : d.labels.env == "uat"
      ]) && alltrue([
      for i in values(output.compute_instances) : i.labels.env == "uat"
    ])
    error_message = "Default labels must include env=uat on disk and instance resources."
  }

  # 3) instance attach ke snapshot-policy-1
  assert {
    condition = anytrue([
      for i in values(output.compute_instances) : contains(i.resource_policies, "snapshot-policy-1")
    ])
    error_message = "Instance must be attached to snapshot-policy-1."
  }
}
