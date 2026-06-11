variable "project_id" {
  description = "The project ID that owns the log sinks."
  type        = string
}

variable "sinks" {
  description = "Map of log sinks to create, keyed by a logical name. Destinations (BigQuery dataset, GCS bucket, Pub/Sub topic) must already exist."
  type = map(object({
    name             = string
    destination_type = string # bigquery | gcs | pubsub
    destination      = string # short resource name: dataset_id | bucket_name | topic_name

    # Project that owns the destination (defaults to var.project_id). Ignored for GCS.
    destination_project = optional(string)

    filter      = optional(string)
    description = optional(string)
    disabled    = optional(bool, false)

    # Whether to create a dedicated writer identity for this sink.
    unique_writer_identity = optional(bool, true)

    # BigQuery only: use date-partitioned tables.
    use_partitioned_tables = optional(bool)

    # Grant the sink's writer identity the role required to write to the
    # destination. Set false if you manage that IAM elsewhere.
    grant_destination_permission = optional(bool, true)

    exclusions = optional(map(object({
      filter      = string
      description = optional(string)
      disabled    = optional(bool, false)
    })), {})
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for k, v in var.sinks :
      contains(["bigquery", "gcs", "pubsub"], v.destination_type)
    ])
    error_message = "Each sink destination_type must be one of bigquery, gcs, or pubsub."
  }
}
