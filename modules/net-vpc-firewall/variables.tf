variable "compute_firewalls" {
  description = "Map of firewall rule configurations."
  type = map(object({
    project     = string
    name        = string
    network     = string
    description = optional(string, "Managed by Terraform")
    direction   = optional(string, "INGRESS")
    priority    = optional(number, 1000)
    disabled    = optional(bool, false)

    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])

    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])

    source_ranges           = optional(list(string), [])
    destination_ranges      = optional(list(string), [])
    source_tags             = optional(list(string), [])
    target_tags             = optional(list(string), [])
    source_service_accounts = optional(list(string), [])
    target_service_accounts = optional(list(string), [])

    log_config = optional(object({
      metadata = optional(string)
    }), {})
  }))

  validation {
    condition = alltrue([
      for k, v in var.compute_firewalls :
      v.direction == "INGRESS" || v.direction == "EGRESS"
    ])
    error_message = "Direction must be either INGRESS or EGRESS."
  }

  validation {
    condition = alltrue([
      for k, v in var.compute_firewalls :
      v.priority == null || (v.priority >= 0 && v.priority <= 65535)
    ])
    error_message = "Priority must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for k, v in var.compute_firewalls :
      length(v.allow) > 0 || length(v.deny) > 0
    ])
    error_message = "At least one allow or deny rule must be specified."
  }
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "network_self_links" {
  description = "Optional map of network name to its self_link (from resource or data)."
  type        = map(string)
  default     = {}
}

variable "resource_prefix" {
  description = "Prefix to be added to resource names."
  type        = string
  default     = null
}
