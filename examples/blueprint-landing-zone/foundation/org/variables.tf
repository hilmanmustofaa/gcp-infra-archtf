variable "organization_id" {
  description = "The GCP Organization ID."
  type        = string
}

variable "billing_account" {
  description = "The Billing Account ID to associate with projects."
  type        = string
}

variable "region" {
  description = "Primary region for infrastructure."
  type        = string
  default     = "asia-southeast2"
}

variable "default_labels" {
  description = "Default labels for all resources."
  type        = map(string)
  default = {
    env     = "foundation"
    project = "landing-zone"
    owner   = "platform-team"
  }
}
