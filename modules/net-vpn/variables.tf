variable "compute_external_vpn_gateways" {
  description = "A map of external VPN gateway objects."
  type = map(object({
    name            = string
    description     = optional(string)
    labels          = optional(map(string), {})
    redundancy_type = optional(string, "SINGLE_IP_INTERNALLY_REDUNDANT")
    interface = list(object({
      id         = number
      ip_address = string
    }))
    project = string
  }))
  default = {}
}

variable "compute_ha_vpn_gateways" {
  description = "A map of HA VPN gateway objects."
  type = map(object({
    name        = string
    network     = string
    description = optional(string)
    vpn_interfaces = list(object({
      id                      = number
      ip_address              = optional(string)
      interconnect_attachment = optional(string)
    }))
    region  = string
    project = string
  }))
  default = {}
}

variable "compute_vpn_tunnels" {
  description = "A map of VPN tunnel objects."
  type = map(object({
    name                            = string
    shared_secret                   = optional(string)
    description                     = optional(string)
    vpn_gateway                     = optional(string)
    vpn_gateway_interface           = optional(number)
    peer_external_gateway           = optional(string)
    peer_external_gateway_interface = optional(number)
    peer_gcp_gateway                = optional(string)
    router                          = optional(string)
    peer_ip                         = optional(string)
    ike_version                     = optional(number, 2)
    local_traffic_selector          = optional(list(string), ["0.0.0.0/0"])
    remote_traffic_selector         = optional(list(string), ["0.0.0.0/0"])
    labels                          = optional(map(string), {})
    region                          = string
    project                         = string
  }))
  default = {}
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
