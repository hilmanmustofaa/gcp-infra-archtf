variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The region to deploy resources (e.g., asia-southeast2)."
  type        = string
  default     = "asia-southeast2"
}

variable "network_onprem_name" {
  description = "Name of the simulated on-premise VPC network."
  type        = string
  default     = "onprem-vpc"
}

variable "network_cloud_name" {
  description = "Name of the cloud VPC network."
  type        = string
  default     = "cloud-vpc"
}

variable "default_labels" {
  description = "Default labels to apply to all resources."
  type        = map(string)
  default = {
    env     = "dev"
    project = "e2e-vpn"
    owner   = "platform-team"
  }
}
