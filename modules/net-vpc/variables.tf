variable "compute_routes" {
  description = "Map of route configurations."
  type = map(object({
    name                        = string
    network                     = string
    dest_range                  = string
    description                 = optional(string)
    priority                    = optional(number, 1000)
    tags                        = optional(list(string))
    next_hop_gateway            = optional(string)
    next_hop_ip                 = optional(string)
    next_hop_instance_self_link = optional(string)
    next_hop_instance_zone      = optional(string)
    next_hop_ilb_self_link      = optional(string)
    project                     = string
  }))
}

variable "data_compute_networks" {
  description = "Map of data sources for compute networks."
  type        = map(any)
  default     = {}
}

variable "data_compute_subnetworks" {
  description = "Map of data sources for compute subnetworks."
  type        = map(any)
  default     = {}
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "networks" {
  description = "Map of VPC network configurations."
  type = map(object({
    project                           = string
    name                              = string
    description                       = optional(string)
    auto_create_subnetworks           = optional(bool, false)
    routing_mode                      = optional(string, "GLOBAL")
    mtu                               = optional(number, 1460)
    delete_default_routes_on_create   = optional(bool, false)
    firewall_policy_enforcement_order = optional(string)
    enable_ula_internal_ipv6          = optional(bool)
    internal_ipv6_range               = optional(string)
  }))
}

variable "policy_based_routes" {
  description = "Map of policy-based route configurations."
  type = map(object({
    name                = string
    network             = string
    description         = optional(string)
    priority            = optional(number, 1000)
    use_default_routing = optional(bool, false)
    next_hop_ilb_ip     = optional(string)
    project             = string
    filter = object({
      protocol_version = optional(string, "IPV4")
      ip_protocol      = string
      dest_range       = string
      src_range        = string
    })
    target = object({
      tags                    = optional(list(string))
      interconnect_attachment = optional(string)
    })
  }))
  default = {}
}

variable "resource_prefix" {
  description = "Prefix to be added to resource names."
  type        = string
  default     = null
}

variable "subnetworks" {
  description = "Map of subnet configurations."
  type = map(object({
    project                  = string
    name                     = string
    network                  = string
    description              = optional(string)
    ip_cidr_range            = string
    region                   = string
    purpose                  = optional(string)
    role                     = optional(string)
    private_ip_google_access = optional(bool, true)
    secondary_ip_range = optional(map(object({
      range_name    = string
      ip_cidr_range = string
    })), {})
    log_config = optional(object({
      aggregation_interval = optional(string)
      flow_sampling        = optional(number)
      metadata             = optional(string)
      metadata_fields      = optional(list(string))
      filter_expr          = optional(string)
    }), {})
    stack_type                 = optional(string)
    ipv6_access_type           = optional(string)
    private_ipv6_google_access = optional(string)
  }))
}
