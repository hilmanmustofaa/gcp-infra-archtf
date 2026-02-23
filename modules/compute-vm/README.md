# Compute VM Module

<!-- BEGIN TOC -->

- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description

This module provides a flexible way to create Compute Engine disks, instance templates, and VMs on Google Cloud. It supports importing existing images or families, advanced encryption options, custom boot and attached disks, network interfaces with NAT, metadata and SSH-key injection, scheduling, shielding, resource policies, and even TLS key generation for use by VMs.

# Feature

- **Image data source**: look up existing images by name, family, filter, or project.
- **Disk creation**: create boot and data disks with custom size, type, labels, encryption keys, snapshots.
- **VM instances**: launch VMs with dynamic blocks for disks, network interfaces, access configs, metadata, scheduling, and service accounts.
- **Instance templates**: batch-create reusable instance templates with rich options (disks, metadata, network, shielding).
- **Resource policies**: attach snapshot schedules or placement policies to disks.
- **TLS key support**: generate private keys for inside-VM use (e.g. SSH/FIPS).
- **Lifecycle management**: ignore metadata churn, create-before-destroy for templates, and more.
- **FinOps labels**: automatically applies standard FinOps labels (`gcp_asset_type`, `gcp_service`, `tf_module`, `tf_layer`, `tf_resource`) to all resources.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [default_labels](variables.tf#L239) | Default labels to be applied to all resources. Must include 'env', 'project', and 'owner' for FinOps governance. | <code>map&#40;string&#41;</code> | ✓ |  |
| [project_id](variables.tf#L268) | The project ID to deploy resources into. | <code>string</code> | ✓ |  |
| [zone](variables.tf#L294) | The zone where resources will be created. | <code>string</code> | ✓ |  |
| [compute_disks](variables.tf#L1) | Map of compute disks to be created. | <code title="map&#40;object&#40;&#123;&#10;  name                      &#61; string&#10;  description               &#61; optional&#40;string&#41;&#10;  labels                    &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  size                      &#61; number&#10;  physical_block_size_bytes &#61; optional&#40;number&#41;&#10;  type                      &#61; string&#10;  image                     &#61; optional&#40;string&#41;&#10;  multi_writer              &#61; optional&#40;bool, false&#41;&#10;  provisioned_iops          &#61; optional&#40;number&#41;&#10;  zone                      &#61; string&#10;  project                   &#61; optional&#40;string&#41;&#10;  source_image_encryption_key &#61; optional&#40;object&#40;&#123;&#10;    raw_key                 &#61; optional&#40;string&#41;&#10;    sha256                  &#61; optional&#40;string&#41;&#10;    kms_key_self_link       &#61; optional&#40;string&#41;&#10;    kms_key_service_account &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;  disk_encryption_key &#61; optional&#40;object&#40;&#123;&#10;    raw_key                 &#61; optional&#40;string&#41;&#10;    sha256                  &#61; optional&#40;string&#41;&#10;    kms_key_self_link       &#61; optional&#40;string&#41;&#10;    kms_key_service_account &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;  source_snapshot_encryption_key &#61; optional&#40;object&#40;&#123;&#10;    raw_key                 &#61; optional&#40;string&#41;&#10;    sha256                  &#61; optional&#40;string&#41;&#10;    kms_key_self_link       &#61; optional&#40;string&#41;&#10;    kms_key_service_account &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [compute_instance_templates](variables.tf#L37) | Map of compute instance templates to be created. | <code title="map&#40;object&#40;&#123;&#10;  name        &#61; string&#10;  name_prefix &#61; optional&#40;string&#41;&#10;&#10;&#10;  disk &#61; list&#40;object&#40;&#123;&#10;    auto_delete  &#61; bool&#10;    boot         &#61; bool&#10;    device_name  &#61; optional&#40;string&#41;&#10;    disk_name    &#61; optional&#40;string&#41;&#10;    source_image &#61; optional&#40;string&#41;&#10;    interface    &#61; optional&#40;string&#41;&#10;    mode         &#61; optional&#40;string&#41;&#10;    source       &#61; optional&#40;string&#41;&#10;    disk_type    &#61; optional&#40;string&#41;&#10;    disk_size_gb &#61; optional&#40;number&#41;&#10;    labels       &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;    type         &#61; optional&#40;string&#41;&#10;    disk_encryption_key &#61; optional&#40;object&#40;&#123;&#10;      kms_key_self_link &#61; string&#10;    &#125;&#41;&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  machine_type            &#61; string&#10;  can_ip_forward          &#61; optional&#40;bool, false&#41;&#10;  description             &#61; optional&#40;string&#41;&#10;  instance_description    &#61; optional&#40;string&#41;&#10;  labels                  &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  metadata                &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  metadata_startup_script &#61; optional&#40;string&#41;&#10;&#10;&#10;  network_interface &#61; list&#40;object&#40;&#123;&#10;    subnetwork         &#61; string&#10;    subnetwork_project &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  project &#61; optional&#40;string&#41;&#10;  region  &#61; optional&#40;string&#41;&#10;&#10;&#10;  scheduling &#61; object&#40;&#123;&#10;    automatic_restart           &#61; optional&#40;bool, true&#41;&#10;    on_host_maintenance         &#61; optional&#40;string, &#34;MIGRATE&#34;&#41;&#10;    preemptible                 &#61; optional&#40;bool, false&#41;&#10;    provisioning_model          &#61; optional&#40;string, &#34;STANDARD&#34;&#41;&#10;    instance_termination_action &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#10;&#10;&#10;  service_account &#61; object&#40;&#123;&#10;    email  &#61; string&#10;    scopes &#61; list&#40;string&#41;&#10;  &#125;&#41;&#10;&#10;&#10;  tags             &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;  min_cpu_platform &#61; optional&#40;string&#41;&#10;&#10;&#10;  shielded_instance_config &#61; optional&#40;object&#40;&#123;&#10;    enable_secure_boot          &#61; bool&#10;    enable_vtpm                 &#61; bool&#10;    enable_integrity_monitoring &#61; bool&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  enable_display &#61; optional&#40;bool, false&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [compute_instances](variables.tf#L104) | Map of compute instances to be created. | <code title="map&#40;object&#40;&#123;&#10;  name         &#61; string&#10;  machine_type &#61; string&#10;  zone         &#61; string&#10;&#10;&#10;  boot_disk &#61; object&#40;&#123;&#10;    auto_delete &#61; bool&#10;    device_name &#61; string&#10;    mode        &#61; string&#10;    source      &#61; string&#10;    disk_encryption_key &#61; optional&#40;object&#40;&#123;&#10;      kms_key_self_link &#61; string&#10;    &#125;&#41;&#41;&#10;  &#125;&#41;&#10;&#10;&#10;  network_interfaces &#61; list&#40;object&#40;&#123;&#10;    subnetwork         &#61; string&#10;    network_ip         &#61; string&#10;    subnetwork_project &#61; optional&#40;string&#41;&#10;    access_config &#61; optional&#40;object&#40;&#123;&#10;      nat_ip       &#61; string&#10;      network_tier &#61; string&#10;    &#125;&#41;&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  allow_stopping_for_update &#61; optional&#40;bool, true&#41;&#10;&#10;&#10;  attached_disk &#61; optional&#40;map&#40;object&#40;&#123;&#10;    source      &#61; string&#10;    device_name &#61; string&#10;    mode        &#61; string&#10;  &#125;&#41;&#41;&#41;&#10;&#10;&#10;  can_ip_forward      &#61; optional&#40;bool, false&#41;&#10;  description         &#61; optional&#40;string&#41;&#10;  deletion_protection &#61; optional&#40;bool, false&#41;&#10;  hostname            &#61; optional&#40;string&#41;&#10;  labels              &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  metadata            &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  project             &#61; optional&#40;string&#41;&#10;&#10;&#10;  scheduling &#61; object&#40;&#123;&#10;    preemptible         &#61; bool&#10;    on_host_maintenance &#61; string&#10;    automatic_restart   &#61; bool&#10;    provisioning_model  &#61; string&#10;  &#125;&#41;&#10;&#10;&#10;  service_account &#61; object&#40;&#123;&#10;    email  &#61; string&#10;    scopes &#61; list&#40;string&#41;&#10;  &#125;&#41;&#10;&#10;&#10;  tags &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;&#10;&#10;  shielded_instance_config &#61; optional&#40;object&#40;&#123;&#10;    enable_secure_boot          &#61; bool&#10;    enable_vtpm                 &#61; bool&#10;    enable_integrity_monitoring &#61; bool&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  enable_display    &#61; optional&#40;bool, false&#41;&#10;  resource_policies &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [compute_resource_policies](variables.tf#L173) | Map of compute resource policies to create. | <code title="map&#40;object&#40;&#123;&#10;  name        &#61; string&#10;  description &#61; optional&#40;string&#41;&#10;  region      &#61; string&#10;  project     &#61; optional&#40;string&#41;&#10;&#10;&#10;  snapshot_schedule_policy &#61; optional&#40;object&#40;&#123;&#10;    hourly_schedule &#61; optional&#40;object&#40;&#123;&#10;      hours_in_cycle &#61; number&#10;      start_time     &#61; string&#10;    &#125;&#41;&#41;&#10;    daily_schedule &#61; optional&#40;object&#40;&#123;&#10;      days_in_cycle &#61; number&#10;      start_time    &#61; string&#10;    &#125;&#41;&#41;&#10;    weekly_schedule &#61; optional&#40;list&#40;object&#40;&#123;&#10;      day_of_weeks &#61; list&#40;object&#40;&#123;&#10;        start_time &#61; string&#10;        day        &#61; string&#10;      &#125;&#41;&#41;&#10;    &#125;&#41;&#41;&#41;&#10;    retention_policy &#61; object&#40;&#123;&#10;      max_retention_days    &#61; number&#10;      on_source_disk_delete &#61; string&#10;    &#125;&#41;&#10;    snapshot_properties &#61; object&#40;&#123;&#10;      labels            &#61; map&#40;string&#41;&#10;      storage_locations &#61; list&#40;string&#41;&#10;      guest_flush       &#61; bool&#10;    &#125;&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  group_placement_policy &#61; optional&#40;object&#40;&#123;&#10;    vm_count                  &#61; number&#10;    availability_domain_count &#61; number&#10;    collocation               &#61; string&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  instance_schedule_policy &#61; optional&#40;object&#40;&#123;&#10;    vm_start_schedule &#61; optional&#40;object&#40;&#123;&#10;      schedule &#61; string&#10;    &#125;&#41;&#41;&#10;    vm_stop_schedule &#61; optional&#40;object&#40;&#123;&#10;      schedule &#61; string&#10;    &#125;&#41;&#41;&#10;    time_zone       &#61; string&#10;    start_time      &#61; optional&#40;string&#41;&#10;    expiration_time &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [data_compute_images](variables.tf#L228) | Map of compute images data source configurations. | <code title="map&#40;object&#40;&#123;&#10;  name    &#61; string&#10;  family  &#61; optional&#40;string&#41;&#10;  filter  &#61; optional&#40;string&#41;&#10;  project &#61; optional&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [disk_snapshots](variables.tf#L253) | List of disk snapshot configurations. | <code title="list&#40;object&#40;&#123;&#10;  disk_name   &#61; string&#10;  policy_name &#61; string&#10;&#125;&#41;&#41;">list&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#91;&#93;</code> |
| [join_separator](variables.tf#L262) | Separator used when joining prefix with resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L273) | Prefix applied to resource names. | <code>string</code> |  | <code>null</code> |
| [templatefiles](variables.tf#L279) | Map of template files for instance metadata startup scripts. | <code title="map&#40;object&#40;&#123;&#10;  template &#61; string&#10;  vars     &#61; map&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [tls_private_keys](variables.tf#L288) | Map of TLS private keys to be created and used in the module. | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [compute_disks](outputs.tf#L1) | Map of compute disks created. | ✓ |
| [compute_images](outputs.tf#L7) | Map of data source compute images used. |  |
| [compute_instance_templates](outputs.tf#L12) | Map of compute instance templates created. |  |
| [compute_instances](outputs.tf#L17) | Map of compute instances created. | ✓ |
| [resource_policies](outputs.tf#L23) | Map of resource policies created. |  |
| [snapshot_schedule_attachments](outputs.tf#L28) | Map of resource policy attachments created. |  |
| [tls_private_keys](outputs.tf#L33) | The input TLS private keys. | ✓ |
<!-- END TFDOC -->
# Example Usage

```hcl
module "compute_vm" {
  source  = "./modules/gcp/compute/compute-vm"
  project_id = "my-project"
  zone       = "us-central1-a"

  data_compute_images = {
    ubuntu = {
      family  = "ubuntu-2004-lts"
      project = "ubuntu-os-cloud"
    }
  }

  compute_disks = {
    boot = {
      name        = "vm-boot-disk"
      size        = 50
      type        = "pd-standard"
      zone        = "us-central1-a"
      labels      = { role = "web" }
      image       = "ubuntu"                # refers to data_compute_images["ubuntu"]
    }
  }

  compute_instances = {
    web1 = {
      name         = "web-server-1"
      machine_type = "e2-medium"
      zone         = "us-central1-a"
      boot_disk = {
        auto_delete = true
        device_name = "boot"
        mode        = "READ_WRITE"
        source      = "boot"                # refers to compute_disks["boot"]
      }
      network_interfaces = [
        {
          subnetwork = "default"
          network_ip = null
          access_config = {
            nat_ip       = null
            network_tier = null
          }
        }
      ]
      metadata = {
        ssh-keys = {
          alice = "ssh-rsa AAA… alice@example.com"
        }
      }
      service_account = {
        email  = "default"
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
      }
      scheduling = {
        preemptible         = false
        on_host_maintenance = "MIGRATE"
        automatic_restart   = true
        provisioning_model  = "STANDARD"
      }
      labels = {
        environment = "prod"
      }
      enable_display = false
    }
  }

  # Optionally create an instance template from the same spec
  compute_instance_templates = {
    web_template = {
      name_prefix            = "web-tpl"
      machine_type           = "e2-medium"
      metadata_startup_script = "init.sh"
      network_interface = [
        { subnetwork = "default" }
      ]
    }
  }

  # Attach a daily snapshot policy to a disk
  compute_resource_policies = {
    daily_snap = {
      name     = "daily-snap"
      region   = "us-central1"
      snapshot_schedule_policy = {
        daily_schedule = {
          days_in_cycle = 1
          start_time    = "00:00"
        }
        retention_policy = {
          max_retention_days    = 7
          on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
        }
        snapshot_properties = {
          storage_locations = ["us-central1"]
        }
      }
    }
  }

  disk_snapshots = [
    {
      disk_name   = "vm-boot-disk"
      policy_name = "daily-snap"
    }
  ]

  # Generate TLS private keys for use by VMs
  tls_private_keys = {
    web_tls = {
      algorithm   = "RSA"
      rsa_bits    = 2048
    }
  }
}
```
