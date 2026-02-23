terraform {
  required_version = ">= 1.8.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.50.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.50.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast2"
}

provider "google-beta" {
  project = var.project_id
  region  = "asia-southeast2"
}

variable "project_id" {
  type        = string
  description = "Project ID."
}

module "compute_vm" {
  source = "git::https://gitlab-ci-token:__GITLAB_TOKEN__@gitlab.ss-wlabid.net/devsecops/terraform-modules-gcp.git//modules/compute-vm?ref=v1.5.0"

  project_id      = var.project_id
  zone            = "asia-southeast2-a"
  resource_prefix = "prod-aml-web"

  default_labels = {
    env         = "prod"
    product     = "aml"
    owner       = "platform-team"
    cost_center = "CC-010"
    managed_by  = "terraform"
    module      = "compute-vm"
  }

  data_compute_images = {
    debian_12 = {
      name    = "debian-12"
      project = "debian-cloud"
    }
  }

  compute_disks     = {}
  compute_instances = {}

  compute_instance_templates = {
    web_template = {
      name        = "web"
      name_prefix = null

      disk = [
        {
          auto_delete         = true
          boot                = true
          device_name         = "boot"
          disk_name           = null
          source_image        = "debian_12"
          interface           = null
          mode                = "READ_WRITE"
          source              = null
          disk_type           = "pd-balanced"
          disk_size_gb        = 50
          labels              = {}
          type                = "PERSISTENT"
          disk_encryption_key = null
        }
      ]

      machine_type            = "e2-standard-2"
      can_ip_forward          = false
      description             = "Prod AML web template."
      instance_description    = "Prod AML web template."
      labels                  = {}
      metadata                = {}
      metadata_startup_script = null

      network_interface = [
        {
          subnetwork         = "prod-aml-subnet"
          subnetwork_project = null
        }
      ]

      project = null
      region  = "asia-southeast2"

      scheduling = {
        automatic_restart           = true
        on_host_maintenance         = "MIGRATE"
        preemptible                 = false
        provisioning_model          = "STANDARD"
        instance_termination_action = null
      }

      service_account = {
        email  = "default"
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
      }

      tags             = ["prod", "aml", "web"]
      min_cpu_platform = null

      shielded_instance_config = null
      enable_display           = false
    }
  }

  compute_resource_policies = {}
  disk_snapshots            = []
  templatefiles             = {}
  tls_private_keys          = {}
}
