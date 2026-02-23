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
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = "asia-southeast2"
  zone    = var.zone
}

variable "project_id" {
  type        = string
  description = "Project ID."
}

variable "zone" {
  type        = string
  description = "Zone for the instance."
  default     = "asia-southeast2-a"
}

module "compute_vm" {
  source = "git::https://gitlab-ci-token:__GITLAB_TOKEN__@gitlab.ss-wlabid.net/devsecops/terraform-modules-gcp.git//modules/compute-vm?ref=v1.5.0"

  project_id      = var.project_id
  zone            = var.zone
  resource_prefix = "dev-aml-web"

  default_labels = {
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
      project = "debian-cloud"
    }
  }

  compute_disks = {
    boot = {
      name                           = "boot"
      description                    = "Boot disk for AML web."
      labels                         = {}
      size                           = 30
      physical_block_size_bytes      = null
      type                           = "pd-balanced"
      image                          = "debian_12"
      multi_writer                   = false
      provisioned_iops               = null
      zone                           = var.zone
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
      zone         = var.zone

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
        "ssh-keys" = {
          "joey" = "default"
        }
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

      tags                     = ["dev", "aml", "web"]
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
