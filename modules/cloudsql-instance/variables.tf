variable "default_labels" {
  description = "Default labels to be applied to all resources."
  type        = map(string)
  default     = {}
}

variable "join_separator" {
  description = "Separator to use when joining prefix to resource names."
  type        = string
  default     = "-"
}

variable "network_lookup" {
  description = "Map of VPC network name → network object (must contain 'id' for private network use)."
  type        = map(any)
  default     = {}
}

variable "resource_prefix" {
  description = "Prefix to be added to resource names."
  type        = string
  default     = null
}


variable "sql_database_instances" {
  description = "Map of Cloud SQL instance configurations."
  type = map(object({
    name                 = string
    region               = string
    database_version     = string
    master_instance_name = optional(string)
    project              = string
    root_password        = optional(string)
    encryption_key_name  = optional(string)
    deletion_protection  = optional(bool, true)
    settings = object({
      tier                        = string
      activation_policy           = optional(string)
      availability_type           = optional(string)
      collation                   = optional(string)
      disk_autoresize             = optional(bool)
      disk_size                   = optional(number)
      disk_type                   = optional(string)
      pricing_plan                = optional(string)
      deletion_protection_enabled = optional(bool)
      user_labels                 = optional(map(string), {})
      database_flags = list(object({
        name  = string
        value = string
      }))
      active_directory_config = list(object({
        domain = string
      }))
      backup_configuration = object({
        enabled                        = bool
        binary_log_enabled             = optional(bool)
        start_time                     = optional(string)
        point_in_time_recovery_enabled = optional(bool)
        location                       = optional(string)
        transaction_log_retention_days = optional(number)
        backup_retention_settings = object({
          retained_backups = number
          retention_unit   = string
        })
      })
      ip_configuration = object({
        ipv4_enabled       = bool
        private_network    = optional(string)
        allocated_ip_range = optional(string)
        authorized_networks = map(object({
          expiration_time = optional(string)
          name            = string
          value           = string
        }))
      })
      location_preference = map(object({
        follow_gae_application = optional(bool)
        zone                   = optional(string)
      }))
      maintenance_window = map(object({
        day          = number
        hour         = number
        update_track = optional(string)
      }))
      insights_config = map(object({
        query_insights_enabled  = bool
        query_string_length     = optional(number)
        record_application_tags = optional(bool)
        record_client_address   = optional(bool)
      }))
    })
  }))
}

variable "sql_databases" {
  description = "Map of Cloud SQL database configurations."
  type = map(object({
    name      = string
    instance  = string
    charset   = optional(string)
    collation = optional(string)
    project   = string
  }))
  default = {}
}

variable "sql_users" {
  description = "Map of Cloud SQL user configurations."
  type = map(object({
    name            = string
    instance        = string
    password        = optional(string)
    type            = optional(string)
    deletion_policy = optional(string)
    host            = optional(string)
    project         = string
  }))
  default = {}
}
