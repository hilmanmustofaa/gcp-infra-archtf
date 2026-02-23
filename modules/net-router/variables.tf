variable "compute_routers" {
  description = "A map of router objects."
  type        = any
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
