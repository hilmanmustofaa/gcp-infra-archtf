variable "project_id" {
  description = "The project ID to create Pub/Sub resources in."
  type        = string
}

variable "resource_prefix" {
  description = "Optional prefix applied to topic/subscription names."
  type        = string
  default     = null
}

variable "join_separator" {
  description = "Separator used when joining prefix with resource names."
  type        = string
  default     = "-"
}

variable "default_labels" {
  description = "Default labels applied to all topics. Must include 'env', 'project', and 'owner' for FinOps governance."
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

variable "topics" {
  description = "Map of Pub/Sub topics to create, keyed by a logical name."
  type = map(object({
    name                       = string
    labels                     = optional(map(string), {})
    kms_key_name               = optional(string) # CMEK
    message_retention_duration = optional(string) # e.g. "86400s"
    # Additive topic IAM: logical key => { role, member } (e.g. roles/pubsub.publisher).
    iam_members = optional(map(object({
      role   = string
      member = string
    })), {})
  }))
  default  = {}
  nullable = false
}

variable "subscriptions" {
  description = "Map of Pub/Sub subscriptions to create, keyed by a logical name."
  type = map(object({
    name  = string
    topic = string # a topic logical key in this module, or a full topic id

    ack_deadline_seconds       = optional(number)
    message_retention_duration = optional(string)
    retain_acked_messages      = optional(bool)
    expiration_ttl             = optional(string) # "" = never expire
    filter                     = optional(string)

    # Push delivery (omit for pull).
    push_endpoint = optional(string)

    # Dead-letter: target topic id + max delivery attempts.
    dead_letter_topic     = optional(string)
    max_delivery_attempts = optional(number)

    # Additive subscription IAM: logical key => { role, member } (subscriber).
    iam_members = optional(map(object({
      role   = string
      member = string
    })), {})
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for s in values(var.subscriptions) :
      (s.dead_letter_topic == null) == (s.max_delivery_attempts == null)
    ])
    error_message = "dead_letter_topic and max_delivery_attempts must be set together (or both omitted)."
  }
}
