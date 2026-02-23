locals {
  # Example: asia-southeast2-a -> asia-southeast2
  default_region = join("-", slice(split("-", var.zone), 0, 2))

  # ========= FinOps module labels (per service module) =========
  # Refer to Cloud Asset Inventory asset types:
  # https://cloud.google.com/asset-inventory/docs/asset-types
  finops_module_labels_default = {
    gcp_asset_type = "compute.googleapis.com/Instance"
    gcp_service    = "compute.googleapis.com"
    tf_module      = "compute-vm"
    tf_layer       = "compute"
    tf_resource    = "instance"
  }
}

data "google_compute_image" "compute_images" {
  provider = google
  for_each = var.data_compute_images

  # Kalau project di-set (mis. public images), pakai name apa adanya.
  # Kalau project null (custom image di project ini), pakai resource_prefix kalau ada.
  # Kalau family di-set, name jadi null biar data source pakai family.
  name = try(each.value.family, null) != null ? null : (each.value.project != null ? each.value.name : (var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name))


  family  = try(each.value.family, null)
  filter  = try(each.value.filter, null)
  project = coalesce(each.value.project, var.project_id)
}

resource "google_compute_disk" "compute_disks" {
  provider = google-beta
  for_each = var.compute_disks

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  description = each.value.description

  labels = merge(
    local.finops_module_labels_default,
    var.default_labels,
    each.value.labels,
    {
      "name"           = each.value.name
      "component"      = each.value.type == "pd-ssd" ? "datadisk" : each.value.type == "pd-balanced" ? "osdisk" : null
      "gcp_asset_type" = "compute.googleapis.com/Disk"
      "tf_resource"    = "disk"
    }
  )

  size                      = each.value.size
  physical_block_size_bytes = each.value.physical_block_size_bytes
  type                      = each.value.type
  image                     = each.value.image != null ? data.google_compute_image.compute_images[each.value.image].self_link : null
  multi_writer              = each.value.multi_writer
  provisioned_iops          = each.value.provisioned_iops
  zone                      = each.value.zone
  project                   = coalesce(each.value.project, var.project_id)

  dynamic "source_image_encryption_key" {
    for_each = each.value.source_image_encryption_key != null ? [each.value.source_image_encryption_key] : []
    content {
      raw_key                 = source_image_encryption_key.value.raw_key
      sha256                  = source_image_encryption_key.value.sha256
      kms_key_self_link       = source_image_encryption_key.value.kms_key_self_link
      kms_key_service_account = source_image_encryption_key.value.kms_key_service_account
    }
  }

  dynamic "disk_encryption_key" {
    for_each = each.value.disk_encryption_key != null ? [each.value.disk_encryption_key] : []
    content {
      raw_key                 = disk_encryption_key.value.raw_key
      sha256                  = disk_encryption_key.value.sha256
      kms_key_self_link       = disk_encryption_key.value.kms_key_self_link
      kms_key_service_account = disk_encryption_key.value.kms_key_service_account
    }
  }

  dynamic "source_snapshot_encryption_key" {
    for_each = each.value.source_snapshot_encryption_key != null ? [each.value.source_snapshot_encryption_key] : []
    content {
      raw_key                 = source_snapshot_encryption_key.value.raw_key
      sha256                  = source_snapshot_encryption_key.value.sha256
      kms_key_self_link       = source_snapshot_encryption_key.value.kms_key_self_link
      kms_key_service_account = source_snapshot_encryption_key.value.kms_key_service_account
    }
  }
}

resource "google_compute_instance" "compute_instances" {
  provider = google-beta
  for_each = var.compute_instances

  name         = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  machine_type = each.value.machine_type
  zone         = each.value.zone

  boot_disk {
    auto_delete       = each.value.boot_disk.auto_delete
    device_name       = each.value.boot_disk.device_name
    mode              = each.value.boot_disk.mode
    source            = google_compute_disk.compute_disks[each.value.boot_disk.source].self_link
    kms_key_self_link = try(each.value.boot_disk.disk_encryption_key.kms_key_self_link, null)
  }

  dynamic "network_interface" {
    for_each = each.value.network_interfaces
    content {
      subnetwork         = network_interface.value.subnetwork
      network_ip         = network_interface.value.network_ip
      subnetwork_project = network_interface.value.subnetwork_project

      dynamic "access_config" {
        for_each = network_interface.value.access_config != null ? [network_interface.value.access_config] : []
        content {
          nat_ip       = access_config.value.nat_ip
          network_tier = access_config.value.network_tier
        }
      }
    }
  }

  allow_stopping_for_update = each.value.allow_stopping_for_update

  dynamic "attached_disk" {
    for_each = each.value.attached_disk != null ? each.value.attached_disk : {}
    content {
      source      = google_compute_disk.compute_disks[attached_disk.value.source].self_link
      device_name = attached_disk.value.device_name
      mode        = attached_disk.value.mode
    }
  }

  can_ip_forward      = each.value.can_ip_forward
  description         = each.value.description
  deletion_protection = each.value.deletion_protection
  hostname            = each.value.hostname

  labels = merge(
    local.finops_module_labels_default,
    var.default_labels,
    each.value.labels,
    {
      "name"      = each.value.name
      "component" = "instance"
    }
  )

  metadata = merge(
    each.value.metadata,
    {
      ssh-keys = try(
        join("\n",
          [
            for user, key in lookup(each.value.metadata, "ssh-keys", {}) :
            "${user}:${chomp(tls_private_key.private_keys[key].public_key_openssh)} ${user}"
          ]
        ),
        null
      )
    }
  )

  project = coalesce(each.value.project, var.project_id)

  scheduling {
    preemptible         = each.value.scheduling.preemptible
    on_host_maintenance = each.value.scheduling.on_host_maintenance
    automatic_restart   = each.value.scheduling.automatic_restart
    provisioning_model  = each.value.scheduling.provisioning_model
  }

  service_account {
    email  = each.value.service_account.email
    scopes = each.value.service_account.scopes
  }

  tags = each.value.tags

  dynamic "shielded_instance_config" {
    for_each = each.value.shielded_instance_config != null ? [each.value.shielded_instance_config] : []
    content {
      enable_secure_boot          = shielded_instance_config.value.enable_secure_boot
      enable_vtpm                 = shielded_instance_config.value.enable_vtpm
      enable_integrity_monitoring = shielded_instance_config.value.enable_integrity_monitoring
    }
  }

  enable_display    = each.value.enable_display
  resource_policies = each.value.resource_policies

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "google_compute_instance_template" "compute_instance_templates" {
  provider = google-beta
  for_each = var.compute_instance_templates

  machine_type = each.value.machine_type

  name_prefix = var.resource_prefix != null ? "${join(var.join_separator, [var.resource_prefix, each.value.name])}-" : "${coalesce(each.value.name_prefix, each.value.name)}-"

  dynamic "disk" {
    for_each = each.value.disk
    content {
      auto_delete  = disk.value.auto_delete
      boot         = disk.value.boot
      disk_size_gb = disk.value.disk_size_gb
      source_image = disk.value.source_image != null ? data.google_compute_image.compute_images[disk.value.source_image].self_link : null
      type         = disk.value.type
      labels = merge(
        local.finops_module_labels_default,
        var.default_labels,
        disk.value.labels,
        {
          "gcp_asset_type" = "compute.googleapis.com/Disk"
          "tf_resource"    = "disk"
        }
      )
      dynamic "disk_encryption_key" {
        for_each = disk.value.disk_encryption_key != null && disk.value.disk_encryption_key.kms_key_self_link != null ? [""] : []
        content {
          kms_key_self_link = disk.value.disk_encryption_key.kms_key_self_link
        }
      }
    }
  }

  can_ip_forward       = each.value.can_ip_forward
  description          = each.value.description
  instance_description = each.value.instance_description

  labels = merge(
    local.finops_module_labels_default,
    var.default_labels,
    each.value.labels,
    {
      "name"           = each.value.name
      "component"      = "template"
      "gcp_asset_type" = "compute.googleapis.com/InstanceTemplate"
      "tf_resource"    = "template"
    }
  )

  metadata = merge(
    each.value.metadata,
    {
      ssh-keys = try(
        join("\n",
          [
            for user, key in lookup(each.value.metadata, "ssh-keys", {}) :
            "${user}:${chomp(tls_private_key.private_keys[key].public_key_openssh)} ${user}"
          ]
        ),
        null
      )
    }
  )

  metadata_startup_script = each.value.metadata_startup_script != null ? templatefile(
    var.templatefiles[each.value.metadata_startup_script].template,
    var.templatefiles[each.value.metadata_startup_script].vars
  ) : null

  dynamic "network_interface" {
    for_each = each.value.network_interface
    content {
      subnetwork         = network_interface.value.subnetwork
      subnetwork_project = network_interface.value.subnetwork_project
    }
  }

  project = coalesce(each.value.project, var.project_id)
  region  = coalesce(each.value.region, local.default_region)

  scheduling {
    automatic_restart           = each.value.scheduling.automatic_restart
    on_host_maintenance         = each.value.scheduling.on_host_maintenance
    preemptible                 = each.value.scheduling.preemptible
    provisioning_model          = each.value.scheduling.provisioning_model
    instance_termination_action = each.value.scheduling.instance_termination_action
  }

  service_account {
    email  = each.value.service_account.email
    scopes = each.value.service_account.scopes
  }

  tags             = each.value.tags
  min_cpu_platform = each.value.min_cpu_platform

  dynamic "shielded_instance_config" {
    for_each = each.value.shielded_instance_config != null ? [each.value.shielded_instance_config] : []
    content {
      enable_secure_boot          = shielded_instance_config.value.enable_secure_boot
      enable_vtpm                 = shielded_instance_config.value.enable_vtpm
      enable_integrity_monitoring = shielded_instance_config.value.enable_integrity_monitoring
    }
  }

  enable_display = each.value.enable_display

  lifecycle {
    create_before_destroy = true
  }
}
