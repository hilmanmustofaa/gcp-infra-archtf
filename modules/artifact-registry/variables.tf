variable "cleanup_policies" {
  description = "Cleanup policies for this repository (DELETE/KEEP rules based on tag state, age and most recent versions)."
  type = map(object({
    action = string # "KEEP" or "DELETE".

    condition = optional(object({
      tag_state             = optional(string) # "TAGGED", "UNTAGGED", "ANY".
      tag_prefixes          = optional(list(string))
      version_name_prefixes = optional(list(string))
      package_name_prefixes = optional(list(string))
      older_than            = optional(string) # e.g. \"30d\".
      newer_than            = optional(string) # e.g. \"7d\".
    }))

    most_recent_versions = optional(object({
      package_name_prefixes = optional(list(string))
      keep_count            = number
    }))
  }))

  default = {}
}

variable "cleanup_policy_dry_run" {
  description = "If true, cleanup policies are evaluated but artifacts are not actually deleted (recommended to keep true first for validation, then set to false once you are confident with the policies)."
  type        = bool
  default     = true
}

variable "description" {
  description = "Optional description for the repository."
  type        = string
  default     = null
}

variable "docker_immutable_tags" {
  description = "Whether to enable immutable tags for Docker repositories (if null, docker_config is omitted; if set, immutable_tags is applied and tagged artifacts cannot be deleted by cleanup policies)."
  type        = bool
  default     = null
}

variable "format" {
  description = "The format of packages stored in the repository. Must be one of: DOCKER, MAVEN, NPM, PYTHON, APT, YUM."
  type        = string

  validation {
    condition = contains(
      ["DOCKER", "MAVEN", "NPM", "PYTHON", "APT", "YUM"],
      var.format
    )
    error_message = "format must be one of: DOCKER, MAVEN, NPM, PYTHON, APT, YUM."
  }
}

variable "kms_key_name" {
  description = "Optional CMEK key for encrypting repository contents (projects/.../locations/.../keyRings/.../cryptoKeys/...)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Additional labels to merge with the module's default FinOps labels (gcp_asset_type, gcp_service, tf_module, tf_layer, tf_resource) and any env/product/cost_center labels you provide."
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Location (region or multi-region) of the Artifact Registry repository (for example: asia-southeast2)."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "maven_allow_snapshot_overwrites" {
  description = "Whether to allow Maven snapshot overwrites (MAVEN format only)."
  type        = bool
  default     = null
}

variable "maven_version_policy" {
  description = "Maven version policy (MAVEN format only). Must be one of: VERSION_POLICY_UNSPECIFIED, RELEASE, SNAPSHOT."
  type        = string
  default     = null
}

variable "mode" {
  description = "Repository mode. Must be one of: STANDARD_REPOSITORY (standard local repository), VIRTUAL_REPOSITORY (virtual repository aggregating upstream repositories), REMOTE_REPOSITORY (remote cache backed by an upstream repository)."
  type        = string
  default     = "STANDARD_REPOSITORY"

  validation {
    condition = contains(
      ["STANDARD_REPOSITORY", "VIRTUAL_REPOSITORY", "REMOTE_REPOSITORY"],
      var.mode
    )
    error_message = "mode must be one of: STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, REMOTE_REPOSITORY."
  }
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "project_id" {
  description = "The project ID where the Artifact Registry repository will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must not be empty."
  }
}

variable "resource_prefix" {
  description = "Prefix to be added to resource names."
  type        = string
  default     = null
}

variable "repository_id" {
  description = "The repository ID (last segment of the repository name)."
  type        = string

  # Org-wide naming convention:
  # - 3–63 characters.
  # - Lowercase letters, digits, hyphen.
  # - Must start with a letter or digit.
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,62}$", var.repository_id))
    error_message = "repository_id must be 3–63 characters, start with a lowercase letter or digit, and contain only lowercase letters, digits, and hyphens."
  }
}
