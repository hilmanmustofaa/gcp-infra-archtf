variable "backup_plans" {
  description = "Map of backup plans keyed by name."
  type = map(object({
    region                            = string
    schedule                          = string
    labels                            = map(string)
    retention_policy_days             = number
    retention_policy_delete_lock_days = optional(number)
    retention_policy_lock             = optional(bool)
    include_volume_data               = bool
    include_secrets                   = bool
    encryption_key                    = optional(string)
    namespaces                        = optional(list(string))
    applications                      = optional(map(list(string)))
  }))
  default = {}
}

variable "certificate_authority_fqdns" {
  description = "List of FQDNs for certificate authority configuration."
  type        = list(string)
  default     = []
}

variable "certificate_authority_secret_uri" {
  description = "Secret URI for the certificate authority in GCP Secret Manager."
  type        = string
  default     = null
  sensitive   = true
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for pod IPs."
  type        = string
}

variable "default_labels" {
  description = "Default labels to apply to the cluster. Must include 'env', 'project', and 'owner' for FinOps governance."
  type        = map(string)

  validation {
    condition = alltrue([
      contains(keys(var.default_labels), "env"),
      contains(keys(var.default_labels), "project"),
      contains(keys(var.default_labels), "owner"),
    ])
    error_message = "Labels must include 'env', 'project', and 'owner' keys for FinOps compliance."
  }
}

variable "default_max_pods_per_node" {
  description = "The default maximum number of pods per node in this cluster."
  type        = number
  default     = 110
}

variable "description" {
  description = "The description of the cluster."
  type        = string
  default     = ""
}

variable "enable_addons" {
  description = "Addons configuration."
  type = object({
    horizontal_pod_autoscaling  = optional(bool, true)
    http_load_balancing         = optional(bool, true)
    network_policy              = optional(bool, false)
    cloudrun                    = optional(bool, false)
    cloudrun_load_balancer_type = optional(string, "EXTERNAL")
    istio = optional(object({
      enable_tls = optional(bool, false)
    }))
  })
  default = {}
}

variable "enable_backup_agent" {
  description = "Enable the GKE Backup Agent."
  type        = bool
  default     = false
}

variable "enable_kubernetes_alpha" {
  description = "Enable Kubernetes Alpha features."
  type        = bool
  default     = false
}

variable "enable_legacy_abac" {
  description = "Enable legacy ABAC authentication."
  type        = bool
  default     = false
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

variable "enable_private_registry" {
  description = "Enable private registry access for the cluster."
  type        = bool
  default     = false
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes features on all nodes."
  type        = bool
  default     = true
}

variable "enable_tpu" {
  description = "Enable Cloud TPU resources."
  type        = bool
  default     = false
}

variable "enable_workload_logs" {
  description = "Enable workload logging."
  type        = bool
  default     = true
}

variable "database_encryption" {
  description = "Application-layer Secrets Encryption settings. REQUIRED: Cloud KMS key must be provided for hardened clusters."
  type = object({
    state    = string
    key_name = string
  })
  # No default — KMS encryption is mandatory for hardened GKE.

  validation {
    condition     = var.database_encryption.state == "ENCRYPTED" && length(var.database_encryption.key_name) > 0
    error_message = "database_encryption must have state='ENCRYPTED' and a valid KMS key_name."
  }
}

variable "gateway_api_channel" {
  description = "Channel to use for Gateway API support."
  type        = string
  default     = null
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "location" {
  description = "The location (region or zone) to host the cluster in."
  type        = string
  default     = null
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

variable "monitoring_components" {
  description = "Monitoring components to enable."
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]
}

variable "name" {
  description = "The name of the cluster."
  type        = string
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

variable "node_locations" {
  description = "The list of zones in which the cluster's nodes are located."
  type        = list(string)
  default     = []
}

variable "node_service_account" {
  description = "REQUIRED: Custom service account for GKE node pools. Default compute SA is not permitted."
  type        = string
  # No default — custom service account is mandatory.

  validation {
    condition     = var.node_service_account != null && length(var.node_service_account) > 0
    error_message = "A custom service account is required. Do not use the default compute service account."
  }
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

variable "upgrade_notifications" {
  description = "Pub/Sub notification config for GKE upgrades."
  type = object({
    topic_id = optional(string)
  })
  default = null
}

variable "workload_pool" {
  description = "The Workload Identity Pool to associate with the cluster."
  type        = string
  default     = null
}
