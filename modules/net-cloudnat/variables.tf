variable "compute_router_nats" {
  description = "Map of Cloud NAT configurations to create."
  type = map(object({
    name                               = string
    project                            = string
    region                             = string
    router                             = string
    type                               = optional(string, "PUBLIC")
    nat_ip_allocate_option             = string
    nat_ips                            = list(string)
    source_subnetwork_ip_ranges_to_nat = string

    subnetwork = optional(map(object({
      name                     = string
      source_ip_ranges_to_nat  = list(string)
      secondary_ip_range_names = optional(list(string))
    })), {})

    min_ports_per_vm                    = optional(number)
    max_ports_per_vm                    = optional(number)
    enable_dynamic_port_allocation      = optional(bool)
    enable_endpoint_independent_mapping = optional(bool)

    udp_idle_timeout_sec             = optional(number)
    icmp_idle_timeout_sec            = optional(number)
    tcp_established_idle_timeout_sec = optional(number)
    tcp_transitory_idle_timeout_sec  = optional(number)
    tcp_time_wait_timeout_sec        = optional(number)

    log_config = object({
      enable = bool
      filter = optional(string)
    })

    endpoint_types = optional(list(string))

    rules = optional(map(object({
      description = optional(string)
      match       = string
      action = object({
        source_nat_active_ips = optional(list(string))
        source_nat_drain_ips  = optional(list(string))
      })
    }))) # Key must be a numeric string (e.g. "100")
  }))
}

variable "nat_ip_lookup" {
  description = "Map of NAT IP names to their static self_link addresses."
  type = map(object({
    self_link = string
  }))
}

variable "network_lookup" {
  description = "Map of subnet names to their self_link references."
  type = map(object({
    self_link = string
  }))
}

variable "resource_prefix" {
  description = "Prefix to be used for resource names."
  type        = string
  default     = null
}

variable "router_lookup" {
  description = "Map of router names to their attributes (must include 'name')."
  type = map(object({
    name = string
  }))
}
