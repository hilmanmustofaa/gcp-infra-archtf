variable "billing_account" {
  description = "The Billing Account ID."
  type        = string
}

variable "folder_id" {
  description = "Folder ID for the Spoke project (usually Production or Development)."
  type        = string
}

variable "host_project_id" {
  description = "The Shared VPC Host Project ID."
  type        = string
}

variable "shared_network_self_link" {
  description = "Self link of the Shared VPC network."
  type        = string
}

variable "default_labels" {
  type = map(string)
  default = {
    env     = "prod"
    project = "spoke-app"
    owner   = "app-team"
  }
}
