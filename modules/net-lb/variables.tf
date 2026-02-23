variable "compute_backend_services" {
  description = "A map of backend service objects."
  type        = any
  default     = {}
}



variable "compute_forwarding_rules" {
  description = "A map of forwarding rule objects."
  type        = any
  default     = {}
}

variable "compute_global_forwarding_rules" {
  description = "A map of global forwarding rule objects."
  type        = any
  default     = {}
}

variable "compute_health_checks" {
  description = "A map of health check objects."
  type        = any
  default     = {}
}

variable "compute_region_backend_services" {
  description = "A map of regional backend service objects."
  type        = any
  default     = {}
}

variable "compute_region_health_checks" {
  description = "A map of regional health check objects."
  type        = any
  default     = {}
}

variable "compute_target_https_proxies" {
  description = "A map of target HTTPS proxy objects."
  type        = any
  default     = {}
}

variable "compute_url_maps" {
  description = "A map of URL map objects."
  type        = any
  default     = {}
}

variable "default_labels" {
  description = "Default labels to apply to all resources."
  type        = map(string)
  default     = {}
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
