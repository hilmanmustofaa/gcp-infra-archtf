locals {
  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "pubsub-googleapis-com--topic"
    gcp_service    = "pubsub-googleapis-com"
    tf_module      = "pubsub-topic"
    tf_layer       = "messaging"
    tf_resource    = "topic"
  }

  finops_labels = merge(
    local.finops_labels_default,
    var.default_labels,
  )

  prefix = var.resource_prefix != null ? "${var.resource_prefix}${var.join_separator}" : ""

  topic_names        = { for k, v in var.topics : k => "${local.prefix}${v.name}" }
  subscription_names = { for k, v in var.subscriptions : k => "${local.prefix}${v.name}" }

  # Resolve a subscription's topic: a logical key in this module's topics, else a literal id.
  subscription_topic = {
    for k, v in var.subscriptions : k => (
      contains(keys(google_pubsub_topic.topics), v.topic)
      ? google_pubsub_topic.topics[v.topic].id
      : v.topic
    )
  }

  # Flatten topics x iam_members for for_each.
  topic_iam = merge([
    for tk, tv in var.topics : {
      for mk, mv in tv.iam_members :
      "${tk}/${mk}" => { topic_key = tk, role = mv.role, member = mv.member }
    }
  ]...)

  # Flatten subscriptions x iam_members for for_each.
  subscription_iam = merge([
    for sk, sv in var.subscriptions : {
      for mk, mv in sv.iam_members :
      "${sk}/${mk}" => { subscription_key = sk, role = mv.role, member = mv.member }
    }
  ]...)
}

resource "google_pubsub_topic" "topics" {
  for_each = var.topics

  project                    = var.project_id
  name                       = local.topic_names[each.key]
  kms_key_name               = each.value.kms_key_name
  message_retention_duration = each.value.message_retention_duration

  labels = merge(local.finops_labels, each.value.labels)
}

resource "google_pubsub_topic_iam_member" "members" {
  for_each = local.topic_iam

  project = var.project_id
  topic   = google_pubsub_topic.topics[each.value.topic_key].name
  role    = each.value.role
  member  = each.value.member
}

resource "google_pubsub_subscription" "subscriptions" {
  for_each = var.subscriptions

  project = var.project_id
  name    = local.subscription_names[each.key]
  topic   = local.subscription_topic[each.key]

  ack_deadline_seconds       = each.value.ack_deadline_seconds
  message_retention_duration = each.value.message_retention_duration
  retain_acked_messages      = each.value.retain_acked_messages
  filter                     = each.value.filter

  labels = local.finops_labels

  dynamic "expiration_policy" {
    for_each = each.value.expiration_ttl != null ? [each.value.expiration_ttl] : []
    content {
      ttl = expiration_policy.value
    }
  }

  dynamic "push_config" {
    for_each = each.value.push_endpoint != null ? [each.value.push_endpoint] : []
    content {
      push_endpoint = push_config.value
    }
  }

  dynamic "dead_letter_policy" {
    for_each = each.value.dead_letter_topic != null ? [each.value] : []
    content {
      dead_letter_topic     = dead_letter_policy.value.dead_letter_topic
      max_delivery_attempts = dead_letter_policy.value.max_delivery_attempts
    }
  }
}

resource "google_pubsub_subscription_iam_member" "members" {
  for_each = local.subscription_iam

  project      = var.project_id
  subscription = google_pubsub_subscription.subscriptions[each.value.subscription_key].name
  role         = each.value.role
  member       = each.value.member
}
