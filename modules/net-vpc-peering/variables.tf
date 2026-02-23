variable "compute_network_peerings" {
  description = "A map of network peering objects."
  type = map(object({
    name                                = string
    network                             = string
    peer_network                        = string
    export_custom_routes                = optional(bool, false)
    import_custom_routes                = optional(bool, false)
    export_subnet_routes_with_public_ip = optional(bool, false)
    import_subnet_routes_with_public_ip = optional(bool, false)
    stack_type                          = optional(string, "IPV4_ONLY")
    peer_create_peering                 = optional(bool, false)
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
