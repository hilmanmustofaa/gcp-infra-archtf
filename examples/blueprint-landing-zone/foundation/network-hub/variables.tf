variable "organization_id" {
  description = "The GCP Organization ID."
  type        = string
}

variable "billing_account" {
  description = "The Billing Account ID."
  type        = string
}

variable "folder_id" {
  description = "Folder ID where the Networking project will reside (usually Common)."
  type        = string
}

variable "region" {
  description = "Primary region."
  type        = string
  default     = "asia-southeast2"
}

variable "default_labels" {
  type = map(string)
  default = {
    env     = "foundation"
    project = "networking-hub"
    owner   = "network-team"
  }
}
