variable "compute_disks" {
  description = "Map of compute disks to be created."
  type = map(object({
    name                      = string
    description               = optional(string)
    labels                    = optional(map(string), {})
    size                      = number
    physical_block_size_bytes = optional(number)
    type                      = string
    image                     = optional(string)
    multi_writer              = optional(bool, false)
    provisioned_iops          = optional(number)
    zone                      = string
    project                   = optional(string)
    source_image_encryption_key = optional(object({
      raw_key                 = optional(string)
      sha256                  = optional(string)
      kms_key_self_link       = optional(string)
      kms_key_service_account = optional(string)
    }))
    disk_encryption_key = optional(object({
      raw_key                 = optional(string)
      sha256                  = optional(string)
      kms_key_self_link       = optional(string)
      kms_key_service_account = optional(string)
    }))
    source_snapshot_encryption_key = optional(object({
      raw_key                 = optional(string)
      sha256                  = optional(string)
      kms_key_self_link       = optional(string)
      kms_key_service_account = optional(string)
    }))
  }))
  default = {}
}

variable "compute_instance_templates" {
  description = "Map of compute instance templates to be created."
  type = map(object({
    name        = string
    name_prefix = optional(string)

    disk = list(object({
      auto_delete  = bool
      boot         = bool
      device_name  = optional(string)
      disk_name    = optional(string)
      source_image = optional(string)
      interface    = optional(string)
      mode         = optional(string)
      source       = optional(string)
      disk_type    = optional(string)
      disk_size_gb = optional(number)
      labels       = optional(map(string), {})
      type         = optional(string)
      disk_encryption_key = optional(object({
        kms_key_self_link = string
      }))
    }))

    machine_type            = string
    can_ip_forward          = optional(bool, false)
    description             = optional(string)
    instance_description    = optional(string)
    labels                  = optional(map(string), {})
    metadata                = optional(map(string), {})
    metadata_startup_script = optional(string)

    network_interface = list(object({
      subnetwork         = string
      subnetwork_project = optional(string)
    }))

    project = optional(string)
    region  = optional(string)

    scheduling = object({
      automatic_restart           = optional(bool, true)
      on_host_maintenance         = optional(string, "MIGRATE")
      preemptible                 = optional(bool, false)
      provisioning_model          = optional(string, "STANDARD")
      instance_termination_action = optional(string)
    })

    service_account = object({
      email  = string
      scopes = list(string)
    })

    tags             = optional(list(string), [])
    min_cpu_platform = optional(string)

    shielded_instance_config = optional(object({
      enable_secure_boot          = bool
      enable_vtpm                 = bool
      enable_integrity_monitoring = bool
    }))

    enable_display = optional(bool, false)
  }))
  default = {}
}

variable "compute_instances" {
  description = "Map of compute instances to be created."
  type = map(object({
    name         = string
    machine_type = string
    zone         = string

    boot_disk = object({
      auto_delete = bool
      device_name = string
      mode        = string
      source      = string
      disk_encryption_key = optional(object({
        kms_key_self_link = string
      }))
    })

    network_interfaces = list(object({
      subnetwork         = string
      network_ip         = string
      subnetwork_project = optional(string)
      access_config = optional(object({
        nat_ip       = string
        network_tier = string
      }))
    }))

    allow_stopping_for_update = optional(bool, true)

    attached_disk = optional(map(object({
      source      = string
      device_name = string
      mode        = string
    })))

    can_ip_forward      = optional(bool, false)
    description         = optional(string)
    deletion_protection = optional(bool, false)
    hostname            = optional(string)
    labels              = optional(map(string), {})
    metadata            = optional(map(string), {})
    project             = optional(string)

    scheduling = object({
      preemptible         = bool
      on_host_maintenance = string
      automatic_restart   = bool
      provisioning_model  = string
    })

    service_account = object({
      email  = string
      scopes = list(string)
    })

    tags = optional(list(string), [])

    shielded_instance_config = optional(object({
      enable_secure_boot          = bool
      enable_vtpm                 = bool
      enable_integrity_monitoring = bool
    }))

    enable_display    = optional(bool, false)
    resource_policies = optional(list(string), [])
  }))
  default = {}
}

variable "compute_resource_policies" {
  description = "Map of compute resource policies to create."
  type = map(object({
    name        = string
    description = optional(string)
    region      = string
    project     = optional(string)

    snapshot_schedule_policy = optional(object({
      hourly_schedule = optional(object({
        hours_in_cycle = number
        start_time     = string
      }))
      daily_schedule = optional(object({
        days_in_cycle = number
        start_time    = string
      }))
      weekly_schedule = optional(list(object({
        day_of_weeks = list(object({
          start_time = string
          day        = string
        }))
      })))
      retention_policy = object({
        max_retention_days    = number
        on_source_disk_delete = string
      })
      snapshot_properties = object({
        labels            = map(string)
        storage_locations = list(string)
        guest_flush       = bool
      })
    }))

    group_placement_policy = optional(object({
      vm_count                  = number
      availability_domain_count = number
      collocation               = string
    }))

    instance_schedule_policy = optional(object({
      vm_start_schedule = optional(object({
        schedule = string
      }))
      vm_stop_schedule = optional(object({
        schedule = string
      }))
      time_zone       = string
      start_time      = optional(string)
      expiration_time = optional(string)
    }))
  }))
  default = {}
}

variable "data_compute_images" {
  description = "Map of compute images data source configurations."
  type = map(object({
    name    = string
    family  = optional(string)
    filter  = optional(string)
    project = optional(string)
  }))
  default = {}
}

variable "default_labels" {
  description = "Default labels to be applied to all resources. Must include 'env', 'project', and 'owner' for FinOps governance."
  type        = map(string)

  validation {
    condition = alltrue([
      contains(keys(var.default_labels), "env"),
      contains(keys(var.default_labels), "project"),
      contains(keys(var.default_labels), "owner"),
    ])
    error_message = "Labels must include 'env', 'project', and 'owner' keys for FinOps compliance."
  }
}

variable "disk_snapshots" {
  description = "List of disk snapshot configurations."
  type = list(object({
    disk_name   = string
    policy_name = string
  }))
  default = []
}

variable "join_separator" {
  description = "Separator used when joining prefix with resource names."
  type        = string
  default     = "-"
}

variable "project_id" {
  description = "The project ID to deploy resources into."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix applied to resource names."
  type        = string
  default     = null
}

variable "templatefiles" {
  description = "Map of template files for instance metadata startup scripts."
  type = map(object({
    template = string
    vars     = map(string)
  }))
  default = {}
}

variable "tls_private_keys" {
  description = "Map of TLS private keys to be created and used in the module."
  type        = map(any)
  default     = {}
}

variable "zone" {
  description = "The zone where resources will be created."
  type        = string
}
