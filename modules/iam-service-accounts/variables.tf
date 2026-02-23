variable "account_id" {
  description = "The account id of the service account."
  type        = string
}

variable "description" {
  description = "Description of the service account."
  type        = string
  default     = null
}

variable "disabled" {
  description = "Whether the service account is disabled."
  type        = bool
  default     = false
}

variable "display_name" {
  description = "Display name of the service account."
  type        = string
  default     = "Terraform-managed service account."
}

variable "generate_key" {
  description = "Whether to generate a service account key."
  type        = bool
  default     = false
}

variable "iam_bindings" {
  description = "Authoritative IAM bindings in {KEY => {role = ROLE, members = [], condition = {}}}. Keys are arbitrary."
  type = map(object({
    members = list(string)
    role    = string
    condition = optional(object({
      expression  = string
      title       = string
      description = optional(string)
    }))
  }))
  nullable = false
  default  = {}
}

variable "iam_bindings_additive" {
  description = "Individual additive IAM bindings. Keys are arbitrary."
  type = map(object({
    member = string
    role   = string
    condition = optional(object({
      expression  = string
      title       = string
      description = optional(string)
    }))
  }))
  nullable = false
  default  = {}
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "labels" {
  description = "Additional FinOps labels to merge with the module's default labels (gcp_asset_type, gcp_service, tf_module, tf_layer, tf_resource)."
  type        = map(string)
  default     = {}
}

variable "resource_prefix" {
  description = "Prefix applied to service account names."
  type        = string
  default     = null
}

variable "project_iam_bindings" {
  description = "Project-level IAM bindings for the service account. Keyed by arbitrary id."
  type = map(object({
    project = optional(string)
    role    = string
  }))
  default = {}
}

variable "project_id" {
  description = "Project id where service account will be created."
  type        = string
}

variable "service_account_create" {
  description = "Create new service account. When set to false, uses a data source to reference an existing service account."
  type        = bool
  default     = true
}

variable "storage_bucket_iam_bindings" {
  description = "Storage bucket IAM bindings for the service account. Keyed by arbitrary id."
  type = map(object({
    bucket = string
    role   = string
  }))
  default = {}
}
