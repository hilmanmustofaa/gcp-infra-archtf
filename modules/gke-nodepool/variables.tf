variable "autoscaling" {
  description = "Autoscaling settings."
  type = object({
    min_node_count       = number
    max_node_count       = number
    total_min_node_count = optional(number)
    total_max_node_count = optional(number)
    location_policy      = optional(string)
  })
  default = null
}

variable "boot_disk_kms_key" {
  description = "KMS key for boot disk encryption."
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "default_labels" {
  description = "Default labels to apply to node pool nodes."
  type        = map(string)
  default     = {}
}

variable "disk_size" {
  description = "Disk size in GB for each node."
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Disk type to use (pd-standard, pd-ssd, etc)."
  type        = string
  default     = "pd-standard"
}

variable "enable_confidential_nodes" {
  description = "Whether to enable Confidential VMs in the node pool."
  type        = bool
  default     = false
}

variable "ephemeral_ssd_count" {
  description = "Number of ephemeral SSDs (ephemeral_storage_config)."
  type        = number
  default     = null
}

variable "gcfs" {
  description = "Enable GCFS for COS_CONTAINERD."
  type        = bool
  default     = false
}

variable "guest_accelerator" {
  description = "GPU configuration block."
  type = object({
    type               = string
    count              = number
    gpu_partition_size = optional(string)
    gpu_driver = optional(object({
      version                    = string
      partition_size             = optional(string)
      max_shared_clients_per_gpu = optional(number)
    }))
  })
  default = null
}

variable "gvnic" {
  description = "Enable GVNIC."
  type        = bool
  default     = false
}

variable "image_type" {
  description = "Image type to use for nodes (COS_CONTAINERD, UBUNTU, etc)."
  type        = string
  default     = null
}

variable "kubelet_config" {
  description = "Kubelet-level config options."
  type = object({
    cpu_manager_policy   = string
    cpu_cfs_quota        = bool
    cpu_cfs_quota_period = string
    pod_pids_limit       = number
  })
  default = null
}

variable "labels" {
  description = "Resource labels assigned to nodes."
  type        = map(string)
  default     = {}
}

variable "linux_node_config" {
  description = "Linux-specific node settings."
  type = object({
    sysctls     = map(string)
    cgroup_mode = string
  })
  default = null
}

variable "local_nvme_ssd_count" {
  description = "Number of local NVMe SSDs to attach."
  type        = number
  default     = 0
}

variable "local_ssd_count" {
  description = "Number of local SSDs to attach."
  type        = number
  default     = 0
}

variable "location" {
  description = "Location/region of the GKE cluster."
  type        = string
}

variable "machine_type" {
  description = "The machine type to use for nodes."
  type        = string
}

variable "management" {
  description = "Management options (auto_repair, auto_upgrade)."
  type = object({
    auto_repair  = bool
    auto_upgrade = bool
  })
  default = null
}

variable "metadata" {
  description = "Metadata key/value pairs assigned to each instance."
  type        = map(string)
  default     = {}
}

variable "min_cpu_platform" {
  description = "Minimum CPU platform."
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the node pool."
  type        = string
}

variable "resource_prefix" {
  description = "Optional prefix to prepend to node pool name."
  type        = string
  default     = null
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "network_config" {
  description = "Pod range network configuration."
  type = object({
    create_pod_range     = bool
    enable_private_nodes = bool
    pod_ipv4_cidr_block  = optional(string)
    pod_range            = string
  })
  default = null
}

variable "node_count" {
  description = "Initial and current node counts."
  type = object({
    initial = number
    current = number
  })
}

variable "node_locations" {
  description = "List of zones where the node pool will be deployed. Leave empty to use cluster default."
  type        = list(string)
  default     = null
}

variable "node_version" {
  description = "GKE node version."
  type        = string
  default     = null
}

variable "oauth_scopes" {
  description = "List of OAuth scopes to be used for node VMs."
  type        = list(string)
  default     = null
}

variable "placement_policy" {
  description = "Node placement policy config."
  type = object({
    type         = string
    policy_name  = optional(string)
    tpu_topology = optional(string)
  })
  default = null
}

variable "preemptible" {
  description = "Use preemptible VMs."
  type        = bool
  default     = false
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "queued_provisioning" {
  description = "Enable queued provisioning."
  type        = bool
  default     = false
}

variable "reservation_affinity" {
  description = "Reservation affinity config."
  type = object({
    consume_reservation_type = string
    key                      = string
    values                   = list(string)
  })
  default = null
}

variable "sandbox_config" {
  description = "Gvisor sandbox configuration."
  type = object({
    sandbox_type = string
  })
  default = null
}

variable "service_account_email" {
  description = "Service account email to use for nodes."
  type        = string
}

variable "shielded_instance_config" {
  description = "Shielded instance config."
  type = object({
    enable_secure_boot          = bool
    enable_integrity_monitoring = bool
  })
  default = null
}

variable "spot" {
  description = "Use Spot VMs instead of preemptible."
  type        = bool
  default     = null
}

variable "tags" {
  description = "Network tags applied to nodes."
  type        = list(string)
  default     = []
}

variable "taints" {
  description = "Taints to apply to nodes."
  type = map(object({
    value  = string
    effect = string
  }))
  default = {}
}

variable "timeouts" {
  description = "Timeout settings for create/update/delete."
  type        = map(string)
  default = {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

variable "upgrade_settings" {
  description = "Node pool upgrade settings."
  type = object({
    max_surge               = number
    max_unavailable         = number
    strategy                = string
    node_pool_soak_duration = string
    batch_percentage        = number
    batch_soak_duration     = string
  })
  default = null
}

variable "workload_metadata_config" {
  description = "Workload metadata config mode."
  type        = string
  default     = "GKE_METADATA"
}
