variable "compute_routers" {
  description = "A map of router objects."
  type = map(object({
    name                          = string
    network                       = string
    description                   = optional(string)
    encrypted_interconnect_router = optional(bool)
    region                        = optional(string)
    project                       = optional(string)
    bgp = optional(object({
      asn                = number
      advertise_mode     = optional(string)
      advertised_groups  = optional(list(string))
      keepalive_interval = optional(number)
      advertised_ip_ranges = optional(list(object({
        range       = string
        description = optional(string)
      })), [])
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
