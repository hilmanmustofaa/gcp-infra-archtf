variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The region to deploy resources (e.g., asia-southeast2)."
  type        = string
  default     = "asia-southeast2"
}

variable "repository_id" {
  description = "The ID of the Artifact Registry repository."
  type        = string
  default     = "hardened-docker-repo"
}

variable "default_labels" {
  description = "Default labels to apply to all resources."
  type        = map(string)
  default = {
    env     = "prod"
    project = "artifact-security"
    owner   = "security-team"
  }
}
