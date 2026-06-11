variable "project_id" {
  description = "The project ID where IAP resources and bindings are managed."
  type        = string
}

# ── IAP OAuth brand (project-level consent screen) ───────────────────────────
# A brand is a singleton per project. Because this module can be called many
# times against the same project, brand creation is OFF by default — create it
# once (here, or in the organization baseline) and reference it elsewhere.

variable "create_brand" {
  description = "Whether to create the project-level IAP OAuth brand. At most one brand may exist per project, so keep this false in modules that may run repeatedly."
  type        = bool
  default     = false
}

variable "brand" {
  description = "IAP OAuth brand configuration. Required when create_brand is true."
  type = object({
    support_email     = string
    application_title = string
  })
  default = null

  validation {
    condition     = !var.create_brand || var.brand != null
    error_message = "brand must be provided when create_brand = true."
  }
}

variable "create_client" {
  description = "Whether to create an IAP OAuth client under the brand. Requires create_brand = true."
  type        = bool
  default     = false

  validation {
    condition     = !var.create_client || var.create_brand
    error_message = "create_client requires create_brand = true (the client is created under the module's brand)."
  }
}

variable "oauth_client" {
  description = "IAP OAuth client configuration. Required when create_client is true."
  type = object({
    display_name = string
  })
  default = null

  validation {
    condition     = !var.create_client || var.oauth_client != null
    error_message = "oauth_client must be provided when create_client = true."
  }
}

# ── IAP tunnel instance IAM (SSH/RDP access to VMs through IAP) ───────────────

variable "tunnel_instance_bindings" {
  description = "Authoritative IAP tunnel IAM bindings per instance, keyed by a logical name."
  type = map(object({
    zone     = string
    instance = string
    role     = optional(string, "roles/iap.tunnelResourceAccessor")
    members  = list(string)
  }))
  default  = {}
  nullable = false
}

variable "tunnel_instance_members" {
  description = "Additive IAP tunnel IAM members per instance, keyed by a logical name."
  type = map(object({
    zone     = string
    instance = string
    role     = optional(string, "roles/iap.tunnelResourceAccessor")
    member   = string
  }))
  default  = {}
  nullable = false
}

# ── IAP web backend service IAM (protect Cloud Run / GKE behind a LB) ─────────

variable "web_backend_bindings" {
  description = "Authoritative IAP web backend service IAM bindings, keyed by a logical name."
  type = map(object({
    web_backend_service = string
    role                = optional(string, "roles/iap.httpsResourceAccessor")
    members             = list(string)
  }))
  default  = {}
  nullable = false
}

variable "web_backend_members" {
  description = "Additive IAP web backend service IAM members, keyed by a logical name."
  type = map(object({
    web_backend_service = string
    role                = optional(string, "roles/iap.httpsResourceAccessor")
    member              = string
  }))
  default  = {}
  nullable = false
}
