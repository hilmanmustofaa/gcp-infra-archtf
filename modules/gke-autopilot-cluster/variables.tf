variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for pod IPs."
  type        = string
}

variable "default_labels" {
  description = "Default labels to apply to the cluster."
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "The description of the cluster."
  type        = string
  default     = ""
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint."
  type        = bool
  default     = false
}

variable "enable_private_nodes" {
  description = "Enable private nodes."
  type        = bool
  default     = true
}

variable "gateway_api_channel" {
  description = "Channel to use for Gateway API support."
  type        = string
  default     = null
}

variable "database_encryption" {
  description = "Application-layer Secrets Encryption settings. The key_name is the name of the KMS key to use."
  type = object({
    state    = string
    key_name = string
  })
  default = null
}

variable "location" {
  description = "The location (region or zone) to host the cluster in."
  type        = string
}

variable "maintenance_window_start_time" {
  description = "Time window specified for daily maintenance operations."
  type        = string
  default     = null
}

variable "master_authorized_networks" {
  description = "List of authorized CIDR blocks to access GKE control plane."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "10.0.0.0/8"
      display_name = "internal-only"
    }
  ]
}

variable "master_ipv4_cidr_block" {
  description = "IP range for the master network."
  type        = string
  default     = "172.16.0.0/28"
}

variable "min_master_version" {
  description = "The minimum version of the master."
  type        = string
  default     = null
}

variable "name" {
  description = "The name of the cluster."
  type        = string
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "network" {
  description = "The VPC network to host the cluster in."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to be added to resource names."
  type        = string
  default     = null
}

variable "node_service_account" {
  description = "The service account to be used by the nodes. If not provided, the default compute service account will be used (not recommended)."
  type        = string
  default     = null
}

variable "project_id" {
  description = "The project ID to host the cluster in."
  type        = string
}

variable "release_channel" {
  description = "GKE release channel to use (e.g. RAPID, REGULAR, STABLE)."
  type        = string
  default     = "REGULAR"
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range for service IPs."
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in."
  type        = string
}

variable "workload_pool" {
  description = "The Workload Identity Pool to associate with the cluster."
  type        = string
  default     = null
}
