variable "data_kms_crypto_keys" {
  description = "Map of existing crypto keys to be imported."
  type = map(object({
    name     = string
    key_ring = string
  }))
  default = {}
}

variable "data_kms_key_rings" {
  description = "Map of existing key rings to be imported."
  type = map(object({
    name     = string
    location = string
    project  = string
  }))
  default = {}
}

variable "default_labels" {
  description = "Default labels to be applied to all resources."
  type        = map(string)
  default     = {}
}

variable "join_separator" {
  description = "Separator to use when joining prefix with resource names."
  type        = string
  default     = "-"
}

variable "kms_crypto_key_iam_bindings" {
  description = "Map of IAM bindings for crypto keys."
  type = map(object({
    crypto_key_id = string
    role          = string
    memebers      = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}

variable "kms_crypto_key_iam_members" {
  description = "Map of IAM members for crypto keys."
  type = map(object({
    crypto_key_id = string
    role          = string
    member        = string
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}

variable "kms_crypto_keys" {
  description = "Map of crypto keys to be created."
  type = map(object({
    name                          = string
    key_ring                      = string
    labels                        = map(string)
    purpose                       = string
    rotation_period               = string
    destroy_scheduled_duration    = optional(string)
    import_only                   = optional(bool)
    skip_initial_version_creation = optional(bool)
    version_template = optional(object({
      algorithm        = string
      protection_level = string
    }))
  }))
  default = {}
}

variable "kms_key_rings" {
  description = "Map of key rings to be created."
  type = map(object({
    name     = string
    location = string
    project  = string
  }))
  default = {}
}

variable "resource_prefix" {
  description = "Prefix to be used for resource names."
  type        = string
  default     = null
}