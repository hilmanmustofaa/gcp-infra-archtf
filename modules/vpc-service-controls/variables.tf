variable "default_labels" {
  description = "Governance metadata. Must include 'env', 'project', and 'owner' for FinOps consistency. Note: Access Context Manager resources are org-scoped and do not carry labels; this is exposed via the finops_labels output only."
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

variable "access_policy_id" {
  description = "Existing Access Context Manager access policy id (e.g. 'accessPolicies/123456'). Required unless create_access_policy is set. Parent for all access levels and perimeters."
  type        = string
  default     = null
}

variable "create_access_policy" {
  description = "Optionally create the org/folder-scoped access policy instead of referencing an existing one. Requires org-level permissions."
  type = object({
    parent = string # e.g. "organizations/123456789"
    title  = string
  })
  default = null
}

variable "access_levels" {
  description = "Map of Access Levels (basic), keyed by a short name (used as the access level id)."
  type = map(object({
    title              = string
    description        = optional(string)
    combining_function = optional(string, "AND") # AND | OR
    conditions = list(object({
      ip_subnetworks         = optional(list(string))
      required_access_levels = optional(list(string))
      members                = optional(list(string))
      regions                = optional(list(string))
      negate                 = optional(bool)
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for k in keys(var.access_levels) : can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", k))])
    error_message = "Access level keys must match ^[a-zA-Z][a-zA-Z0-9_]*$ (letters, digits, underscores; no dashes)."
  }
}

variable "service_perimeters" {
  description = "Map of Service Perimeters, keyed by a short name (used as the perimeter id)."
  type = map(object({
    title          = string
    description    = optional(string)
    perimeter_type = optional(string, "PERIMETER_TYPE_REGULAR") # REGULAR | BRIDGE

    resources           = optional(list(string), []) # ["projects/123456789"]
    restricted_services = optional(list(string), []) # ["bigquery.googleapis.com", ...]
    access_levels       = optional(list(string), []) # access level logical keys (this module) or full names

    vpc_accessible_services = optional(object({
      enable_restriction = bool
      allowed_services   = list(string) # service names or ["RESTRICTED-SERVICES"]
    }))

    ingress_policies = optional(list(object({
      from = object({
        identity_type = optional(string) # ANY_IDENTITY | ANY_USER_ACCOUNT | ANY_SERVICE_ACCOUNT
        identities    = optional(list(string))
        sources = optional(list(object({
          access_level = optional(string) # access level logical key or full name
          resource     = optional(string) # "projects/123" or "*"
        })), [])
      })
      to = object({
        resources = optional(list(string), ["*"])
        operations = optional(list(object({
          service_name = string
          methods      = optional(list(string), ["*"])
        })), [])
      })
    })), [])

    egress_policies = optional(list(object({
      from = object({
        identity_type = optional(string)
        identities    = optional(list(string))
      })
      to = object({
        resources          = optional(list(string), ["*"])
        external_resources = optional(list(string))
        operations = optional(list(object({
          service_name = string
          methods      = optional(list(string), ["*"])
        })), [])
      })
    })), [])
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for k in keys(var.service_perimeters) : can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", k))])
    error_message = "Perimeter keys must match ^[a-zA-Z][a-zA-Z0-9_]*$ (letters, digits, underscores; no dashes)."
  }
}
