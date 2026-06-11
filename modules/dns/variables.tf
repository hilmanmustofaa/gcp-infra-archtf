variable "data_dns_managed_zones" {
  description = "Map of imported (existing) DNS managed zones to look up."
  type = map(object({
    name    = string
    project = optional(string)
  }))
  default = {}
}

variable "default_labels" {
  description = "Default labels applied to all DNS resources."
  type        = map(string)
  default     = {}
}

variable "dns_managed_zones" {
  description = "Map of DNS managed zone definitions."
  type = map(object({
    name        = string
    dns_name    = string
    description = optional(string)
    visibility  = optional(string)
    project     = optional(string)
    labels      = optional(map(string), {})
    dnssec_config = optional(object({
      kind          = optional(string)
      non_existence = optional(string)
      state         = optional(string)
      default_key_specs = optional(list(object({
        algorithm  = optional(string)
        key_length = optional(number)
        key_type   = optional(string)
        kind       = optional(string)
      })), [])
    }))
    private_visibility_config = optional(object({
      networks = optional(list(string), [])
    }))
    forwarding_config = optional(object({
      target_name_servers = optional(list(object({
        ipv4_address    = string
        forwarding_path = optional(string)
      })), [])
    }))
    peering_config = optional(object({
      target_network = optional(list(string), [])
    }))
  }))
  default = {}
}

variable "dns_policies" {
  description = "Map of DNS policies."
  type = map(object({
    name                      = string
    description               = optional(string)
    project                   = optional(string)
    enable_inbound_forwarding = optional(bool)
    enable_logging            = optional(bool)
    alternative_name_server_config = optional(object({
      target_name_servers = optional(list(object({
        ipv4_address    = string
        forwarding_path = optional(string)
      })), [])
    }), {})
    networks = optional(list(string), [])
  }))
  default = {}
}

variable "dns_record_sets" {
  description = "Map of DNS record sets."
  type = map(object({
    name         = optional(string)
    type         = string
    ttl          = optional(number)
    managed_zone = string
    rrdatas      = optional(list(string))
    project      = optional(string)
    routing_policy = optional(object({
      wrr = optional(list(object({
        weight  = number
        rrdatas = list(string)
      })), [])
      geo = optional(list(object({
        location = string
        rrdatas  = list(string)
      })), [])
    }))
  }))
  default = {}
}

variable "join_separator" {
  description = "Separator used when joining resource names."
  type        = string
  default     = "-"
}

variable "network_lookup" {
  description = "Lookup map of network name => network object (self_link) for DNS policy/zone network bindings."
  type = map(object({
    self_link = string
  }))
  default = {}
}

variable "project_id" {
  description = "The project ID where DNS resources will be created."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to prepend to resource names."
  type        = string
  default     = null
}
