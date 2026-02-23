variable "default_labels" {
  description = "Default labels to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "external_addresses" {
  description = "Map of external IP addresses."
  type = map(object({
    name         = optional(string)
    region       = string
    address      = optional(string)
    description  = optional(string)
    labels       = optional(map(string), {})
    network_tier = optional(string)
    subnetwork   = optional(string)
  }))
  default = {}
}

variable "global_addresses" {
  description = "Map of global IP addresses."
  type = map(object({
    name        = optional(string)
    description = optional(string)
    ip_version  = optional(string)
    labels      = optional(map(string), {})
  }))
  default = {}
}

variable "internal_addresses" {
  description = "Map of internal IP addresses."
  type = map(object({
    name        = optional(string)
    region      = string
    address     = optional(string)
    description = optional(string)
    subnetwork  = string
    labels      = optional(map(string), {})
    purpose     = optional(string)
  }))
  default = {}
}

variable "ipsec_interconnect_addresses" {
  description = "Map of IP addresses for IPSEC Interconnect."
  type = map(object({
    name          = optional(string)
    description   = optional(string)
    address       = string
    region        = string
    network       = string
    prefix_length = number
    labels        = optional(map(string), {})
  }))
  default = {}
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to be added to resource names."
  type        = string
  default     = null
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "psa_addresses" {
  description = "Map of Private Service Access addresses."
  type = map(object({
    name          = optional(string)
    description   = optional(string)
    address       = string
    network       = string
    prefix_length = number
    labels        = optional(map(string), {})
  }))
  default = {}
}
