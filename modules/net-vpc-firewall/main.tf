locals {
  network_lookup = var.network_self_links
}

resource "google_compute_firewall" "compute_firewalls" {
  provider = google-beta
  for_each = var.compute_firewalls

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  network     = try(local.network_lookup[each.value.network], each.value.network)
  project     = each.value.project
  description = each.value.description

  direction = each.value.direction
  priority  = each.value.priority
  disabled  = each.value.disabled

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = try(allow.value.ports, null)
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = try(deny.value.ports, null)
    }
  }

  source_ranges           = length(each.value.source_ranges) > 0 ? each.value.source_ranges : null
  destination_ranges      = length(each.value.destination_ranges) > 0 ? each.value.destination_ranges : null
  source_tags             = length(each.value.source_tags) > 0 ? each.value.source_tags : null
  target_tags             = length(each.value.target_tags) > 0 ? each.value.target_tags : null
  source_service_accounts = length(each.value.source_service_accounts) > 0 ? each.value.source_service_accounts : null
  target_service_accounts = length(each.value.target_service_accounts) > 0 ? each.value.target_service_accounts : null

  dynamic "log_config" {
    for_each = try(each.value.log_config.metadata, null) != null ? [1] : []
    content {
      metadata = each.value.log_config.metadata
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.direction == "INGRESS" && length(each.value.source_ranges) > 0) ||
        (each.value.direction == "EGRESS" && length(each.value.destination_ranges) > 0) ||
        length(each.value.source_service_accounts) > 0 ||
        length(each.value.source_tags) > 0
      )
      error_message = "Firewall rule ${each.value.name} must specify either ranges, service accounts, or tags based on direction."
    }
  }
}
