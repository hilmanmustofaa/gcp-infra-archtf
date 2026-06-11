variable "default_labels" {
  description = "Default labels to be applied to all buckets."
  type        = map(string)
  default     = {}
}

variable "join_separator" {
  description = "Separator used when joining prefix with resource names."
  type        = string
  default     = "-"
}

variable "objects" {
  description = "Map of objects to be created in the buckets."
  type = map(object({
    bucket              = string
    name                = string
    metadata            = optional(map(string))
    content             = optional(string)
    source              = optional(string)
    cache_control       = optional(string)
    content_disposition = optional(string)
    content_encoding    = optional(string)
    content_language    = optional(string)
    content_type        = optional(string)
    storage_class       = optional(string)
    customer_encryption = optional(object({
      encryption_algorithm = string
      encryption_key       = string
    }))
  }))
  default = {}
}

variable "project_id" {
  description = "The ID of the project where the buckets will be created."
  type        = string
}

variable "resource_prefix" {
  description = "Optional prefix for resource names."
  type        = string
  default     = null
}

variable "storage_buckets" {
  description = "Map of storage buckets to create with their configurations."
  type = map(object({
    name                        = string
    location                    = string
    labels                      = optional(map(string), {})
    force_destroy               = optional(bool, false)
    uniform_bucket_level_access = optional(bool, true)
    public_access_prevention    = optional(string, "inherited")
    storage_class               = optional(string)

    versioning = optional(object({
      enabled = optional(bool, false)
    }), {})

    autoclass = optional(object({
      enabled                = bool
      terminal_storage_class = optional(string)
    }))

    encryption = optional(object({
      kms_key_name = string
    }))

    lifecycle_rules = optional(map(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                        = optional(number)
        created_before             = optional(string)
        custom_time_before         = optional(string)
        days_since_custom_time     = optional(number)
        days_since_noncurrent_time = optional(number)
        matches_prefix             = optional(list(string))
        matches_storage_class      = optional(list(string))
        matches_suffix             = optional(list(string))
        noncurrent_time_before     = optional(string)
        num_newer_versions         = optional(number)
        with_state                 = optional(string)
      })
    })))

    retention_policy = optional(object({
      is_locked        = optional(bool, false)
      retention_period = optional(number)
    }), {})

    logging = optional(object({
      log_bucket        = optional(string)
      log_object_prefix = optional(string)
    }), {})

    website = optional(object({
      main_page_suffix = optional(string)
      not_found_page   = optional(string)
    }))

    custom_placement_config = optional(list(string))
  }))
  default = {}

  # Autoclass and lifecycle_rules are mutually exclusive on the same bucket
  # (GCP hard constraint: Autoclass manages transitions, so manual lifecycle
  # storage-class rules cannot coexist).
  validation {
    condition = alltrue([
      for k, v in var.storage_buckets :
      !(try(v.autoclass.enabled, false) && length(coalesce(v.lifecycle_rules, {})) > 0)
    ])
    error_message = "A bucket cannot enable autoclass and define lifecycle_rules at the same time (GCP hard constraint)."
  }

  # Autoclass terminal_storage_class, when set, must be NEARLINE or ARCHIVE.
  validation {
    condition = alltrue([
      for k, v in var.storage_buckets :
      try(v.autoclass.terminal_storage_class, null) == null ? true : contains(["NEARLINE", "ARCHIVE"], v.autoclass.terminal_storage_class)
    ])
    error_message = "autoclass.terminal_storage_class must be either NEARLINE or ARCHIVE."
  }
}
