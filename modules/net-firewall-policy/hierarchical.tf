resource "google_compute_firewall_policy" "hierarchical" {
  count       = local.use_hierarchical ? 1 : 0
  parent      = var.parent_id
  short_name  = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, var.name]) : var.name
  description = var.description
}

resource "google_compute_firewall_policy_association" "hierarchical" {
  for_each          = local.use_hierarchical ? var.attachments : {}
  name              = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, "${var.name}-${each.key}"]) : "${var.name}-${each.key}"
  attachment_target = each.value
  firewall_policy   = google_compute_firewall_policy.hierarchical[0].name
}

resource "google_compute_firewall_policy_rule" "hierarchical" {
  # Terraform's type system barfs in the condition if we use the locals map
  for_each = toset(
    local.use_hierarchical ? keys(local.rules) : []
  )
  firewall_policy         = google_compute_firewall_policy.hierarchical[0].name
  action                  = local.rules[each.key].action
  description             = local.rules[each.key].description
  direction               = local.rules[each.key].direction
  disabled                = local.rules[each.key].disabled
  enable_logging          = local.rules[each.key].enable_logging
  priority                = local.rules[each.key].priority
  target_resources        = local.rules[each.key].target_resources
  target_service_accounts = local.rules[each.key].target_service_accounts
  tls_inspect             = local.rules[each.key].tls_inspect
  security_profile_group = try(
    var.security_profile_group_ids[local.rules[each.key].security_profile_group],
    local.rules[each.key].security_profile_group
  )
  match {
    dest_ip_ranges = local.rules[each.key].match.destination_ranges
    src_ip_ranges  = local.rules[each.key].match.source_ranges
    dest_address_groups = (
      local.rules[each.key].direction == "EGRESS"
      ? local.rules[each.key].match.address_groups
      : null
    )
    dest_fqdns = (
      local.rules[each.key].direction == "EGRESS"
      ? local.rules[each.key].match.fqdns
      : null
    )
    dest_region_codes = (
      local.rules[each.key].direction == "EGRESS"
      ? local.rules[each.key].match.region_codes
      : null
    )
    dest_threat_intelligences = (
      local.rules[each.key].direction == "EGRESS"
      ? local.rules[each.key].match.threat_intelligences
      : null
    )
    src_address_groups = (
      local.rules[each.key].direction == "INGRESS"
      ? local.rules[each.key].match.address_groups
      : null
    )
    src_fqdns = (
      local.rules[each.key].direction == "INGRESS"
      ? local.rules[each.key].match.fqdns
      : null
    )
    src_region_codes = (
      local.rules[each.key].direction == "INGRESS"
      ? local.rules[each.key].match.region_codes
      : null
    )
    src_threat_intelligences = (
      local.rules[each.key].direction == "INGRESS"
      ? local.rules[each.key].match.threat_intelligences
      : null
    )
    dynamic "layer4_configs" {
      for_each = local.rules[each.key].match.layer4_configs
      content {
        ip_protocol = layer4_configs.value.protocol
        ports       = layer4_configs.value.ports
      }
    }
  }
}
