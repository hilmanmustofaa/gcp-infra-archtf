variable "project_id" {
  description = "The project ID to create secrets in."
  type        = string
}

variable "resource_prefix" {
  description = "Optional prefix applied to secret IDs."
  type        = string
  default     = null
}

variable "join_separator" {
  description = "Separator used when joining prefix with resource names."
  type        = string
  default     = "-"
}

variable "default_labels" {
  description = "Default labels applied to all secrets. Must include 'env', 'project', and 'owner' for FinOps governance."
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

variable "secrets" {
  description = "Map of Secret Manager secrets to create, keyed by a logical name."
  type = map(object({
    secret_id   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    # Replication: set automatic = true, OR provide user_managed_replicas (with
    # optional per-replica CMEK). Exactly one of the two must be configured.
    replication = object({
      automatic = optional(bool, false)
      user_managed_replicas = optional(list(object({
        location     = string
        kms_key_name = optional(string)
      })), [])
    })

    # Rotation requires at least one Pub/Sub topic to be configured.
    rotation = optional(object({
      next_rotation_time = optional(string)
      rotation_period    = optional(string)
    }))

    # Pub/Sub topic resource names that receive secret event/rotation messages.
    topics = optional(list(string), [])

    # Expiry: ttl and expire_time are mutually exclusive.
    ttl         = optional(string)
    expire_time = optional(string)

    version_aliases = optional(map(string), {})

    # Optional initial secret value. Prefer managing secret material out-of-band;
    # only use this for bootstrap values. Treated as sensitive.
    secret_data = optional(string)

    # Authoritative IAM bindings: logical key => { role, members }.
    iam_bindings = optional(map(object({
      role    = string
      members = list(string)
    })), {})

    # Additive IAM members: logical key => { role, member }.
    iam_members = optional(map(object({
      role   = string
      member = string
    })), {})
  }))
  default  = {}
  nullable = false

  # Exactly one replication strategy per secret.
  validation {
    condition = alltrue([
      for k, v in var.secrets :
      (v.replication.automatic == true) != (length(v.replication.user_managed_replicas) > 0)
    ])
    error_message = "Each secret must set replication.automatic = true OR provide user_managed_replicas, but not both/neither."
  }

  # Rotation requires at least one topic (GCP API constraint).
  validation {
    condition = alltrue([
      for k, v in var.secrets :
      v.rotation == null ? true : length(v.topics) > 0
    ])
    error_message = "A secret with a rotation policy must also define at least one Pub/Sub topic."
  }

  # ttl and expire_time are mutually exclusive.
  validation {
    condition = alltrue([
      for k, v in var.secrets :
      !(v.ttl != null && v.expire_time != null)
    ])
    error_message = "Set either ttl or expire_time on a secret, not both."
  }
}
