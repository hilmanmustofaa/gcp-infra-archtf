mock_provider "google" {}
mock_provider "google-beta" {}

run "plan_basic_instance" {
  command = plan

  variables {
    project_id      = "joey-dev-project"
    zone            = "asia-southeast2-a"
    resource_prefix = "dev-aml-web"
    join_separator  = "-"

    default_labels = {
      project     = "aml"
      env         = "dev"
      product     = "aml"
      owner       = "devops-team"
      cost_center = "CC-001"
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
        description                    = "Boot disk for AML web."
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
            subnetwork         = "dev-aml-subnet"
            network_ip         = "10.10.0.10"
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
        description               = "Dev AML web instance."
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
        resource_policies        = []
      }
    }

    compute_instance_templates = {}
    compute_resource_policies  = {}
    disk_snapshots             = []
    templatefiles              = {}

    tls_private_keys = {
      default = {
        algorithm   = "RSA"
        rsa_bits    = 4096
        ecdsa_curve = null
      }
    }
  }

  # === ASSERTIONS ===

  # 1) Tepat 1 disk dan 1 instance
  assert {
    condition = (
      length(output.compute_disks) == 1 &&
      length(output.compute_instances) == 1
    )
    error_message = "Expected exactly 1 disk and 1 instance to be created."
  }

  # 2) Semua disk & instance punya label env=dev
  assert {
    condition = alltrue([
      for d in values(output.compute_disks) : d.labels.env == "dev"
      ]) && alltrue([
      for i in values(output.compute_instances) : i.labels.env == "dev"
    ])
    error_message = "Default labels must include env=dev on all created resources."
  }
}
