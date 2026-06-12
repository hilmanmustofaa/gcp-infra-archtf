variable "project_id" {
  description = "The project ID to create BigQuery datasets in."
  type        = string
}

variable "resource_prefix" {
  description = "Optional prefix applied to dataset IDs (joined with '_')."
  type        = string
  default     = null
}

variable "default_labels" {
  description = "Default labels applied to all datasets. Must include 'env', 'project', and 'owner' for FinOps governance."
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

variable "datasets" {
  description = "Map of BigQuery datasets to create, keyed by a logical name."
  type = map(object({
    dataset_id  = string
    description = optional(string)
    location    = optional(string, "asia-southeast2")

    default_table_expiration_ms     = optional(number)
    default_partition_expiration_ms = optional(number)
    max_time_travel_hours           = optional(number)
    delete_contents_on_destroy      = optional(bool, false)

    # CMEK (banking/govt). Full Cloud KMS key resource name.
    kms_key_name = optional(string)

    labels = optional(map(string), {})

    # Additive IAM grants: logical key => { role, member }.
    iam_members = optional(map(object({
      role   = string
      member = string
    })), {})
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for k, v in var.datasets :
      can(regex("^[a-zA-Z0-9_]+$", v.dataset_id))
    ])
    error_message = "dataset_id may only contain letters, numbers, and underscores."
  }
}
