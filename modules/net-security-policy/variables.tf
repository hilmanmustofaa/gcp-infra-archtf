variable "compute_security_policies" {
  description = "A map of Cloud Armor security policy objects."
  type = map(object({
    name        = string
    description = optional(string)
    project     = optional(string)
    type        = optional(string)
    rule = list(object({
      action      = string
      priority    = number
      description = optional(string)
      preview     = optional(bool)
      match = object({
        versioned_expr = optional(string)
        config = optional(object({
          src_ip_ranges = optional(list(string), [])
        }))
        expr = optional(object({
          expression = optional(string)
        }))
      })
      rate_limit_options = optional(object({
        ban_duration_sec     = optional(number)
        ban_threshold        = object({ count = number, interval_sec = number })
        conform_action       = optional(string)
        enforce_on_key       = optional(string)
        enforce_on_key_name  = optional(string)
        exceed_action        = optional(string)
        rate_limit_threshold = object({ count = number, interval_sec = number })
      }))
      redirect_options = optional(object({
        type   = string
        target = optional(string)
      }))
    }))
    advanced_options_config = optional(object({
      json_parsing = optional(string)
      log_level    = optional(string)
    }))
    adaptive_protection_config = optional(object({
      layer_7_ddos_defense_config = object({
        enable          = bool
        rule_visibility = optional(string)
      })
    }))
  }))
  default = {}
}


variable "join_separator" {
  description = "The separator to use when joining the prefix and the name."
  type        = string
  default     = "-"
}

variable "resource_prefix" {
  description = "A prefix for the resource names."
  type        = string
  default     = null
}
