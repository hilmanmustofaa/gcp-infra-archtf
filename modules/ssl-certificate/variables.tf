variable "compute_managed_ssl_certificates" {
  description = "A map of managed SSL certificate objects. Note: google_compute_managed_ssl_certificate does not support labels."
  type = map(object({
    name        = string
    description = optional(string)
    project     = optional(string)
    type        = optional(string, "MANAGED")
    managed = object({
      domains = list(string)
    })
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
