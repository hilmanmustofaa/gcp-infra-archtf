variable "data_dns_managed_zones" {
  description = "Map of imported DNS managed zones."
  type        = map(any)
  default     = {}
}

variable "default_labels" {
  description = "Default labels applied to all DNS resources."
  type        = map(string)
  default     = {}
}

variable "dns_managed_zones" {
  description = "Map of DNS managed zone definitions."
  type        = map(any)
  default     = {}
}

variable "dns_policies" {
  description = "Map of DNS policies."
  type        = map(any)
  default     = {}
}

variable "dns_record_sets" {
  description = "Map of DNS record sets."
  type        = map(any)
  default     = {}
}

variable "join_separator" {
  description = "Separator used when joining resource names."
  type        = string
  default     = "-"
}

variable "network_lookup" {
  description = "Lookup map for networks to bind DNS policies."
  type        = map(any)
  default     = {}
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