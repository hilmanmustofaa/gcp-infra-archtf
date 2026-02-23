mock_provider "google" {}
mock_provider "google-beta" {}

run "plan_finops_labels" {
  command = plan

  variables {
    project_id      = "joey-dev-project"
    zone            = "asia-southeast2-a"
    resource_prefix = "dev-aml-web"
    join_separator  = "-"

    default_labels = {
      project = "aml"
      env     = "dev"
      owner   = "finance"
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
        name        = "boot"
        description = "Boot disk"
        labels      = {}
        size        = 50
        type        = "pd-balanced"
        image       = "debian_12"
        zone        = "asia-southeast2-a"
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
            subnetwork = "dev-aml-subnet"
            network_ip = "10.10.0.10"
          }
        ]
        service_account = {
          email  = "default"
          scopes = ["cloud-platform"]
        }
        scheduling = {
          preemptible         = false
          on_host_maintenance = "MIGRATE"
          automatic_restart   = true
          provisioning_model  = "STANDARD"
        }
      }
    }
  }



  assert {
    condition = (
      output.compute_instances["vm1"].labels.gcp_asset_type == "compute.googleapis.com/Instance" &&
      output.compute_instances["vm1"].labels.tf_resource == "instance" &&
      output.compute_instances["vm1"].labels.tf_module == "compute-vm" &&
      output.compute_instances["vm1"].labels.gcp_service == "compute.googleapis.com"
    )
    error_message = "Instance labels are incorrect"
  }

  assert {
    condition = (
      output.compute_disks["boot"].labels.gcp_asset_type == "compute.googleapis.com/Disk" &&
      output.compute_disks["boot"].labels.tf_resource == "disk" &&
      output.compute_disks["boot"].labels.tf_module == "compute-vm" &&
      output.compute_disks["boot"].labels.gcp_service == "compute.googleapis.com"
    )
    error_message = "Disk labels are incorrect"
  }
}
