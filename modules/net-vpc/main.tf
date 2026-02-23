# -----------------------------------------
# Compute Network
# -----------------------------------------
resource "google_compute_network" "network" {
  provider                                  = google-beta
  for_each                                  = var.networks
  project                                   = each.value.project
  name                                      = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  description                               = each.value.description
  auto_create_subnetworks                   = each.value.auto_create_subnetworks
  routing_mode                              = each.value.routing_mode
  mtu                                       = each.value.mtu
  delete_default_routes_on_create           = each.value.delete_default_routes_on_create
  network_firewall_policy_enforcement_order = try(each.value.firewall_policy_enforcement_order, "AFTER_CLASSIC_FIREWALL")
  enable_ula_internal_ipv6                  = try(each.value.enable_ula_internal_ipv6, false)
  internal_ipv6_range                       = try(each.value.internal_ipv6_range, null)
}

# -----------------------------------------
# Compute Subnetwork
# -----------------------------------------
resource "google_compute_subnetwork" "subnetwork" {
  provider                   = google-beta
  for_each                   = var.subnetworks
  project                    = each.value.project
  name                       = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  network                    = google_compute_network.network[each.value.network].self_link
  description                = each.value.description
  ip_cidr_range              = each.value.ip_cidr_range
  region                     = each.value.region
  private_ip_google_access   = each.value.private_ip_google_access
  purpose                    = each.value.purpose
  role                       = each.value.role
  stack_type                 = each.value.stack_type
  ipv6_access_type           = each.value.ipv6_access_type
  private_ipv6_google_access = each.value.private_ipv6_google_access

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_range
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config.aggregation_interval != null || each.value.log_config.flow_sampling != null || each.value.log_config.metadata != null ? { "log_config" = each.value.log_config } : {}
    content {
      aggregation_interval = each.value.log_config.aggregation_interval
      flow_sampling        = each.value.log_config.flow_sampling
      metadata             = each.value.log_config.metadata
      metadata_fields      = each.value.log_config.metadata_fields
      filter_expr          = each.value.log_config.filter_expr
    }
  }
}

# -----------------------------------------
# Data Sources: Compute Network & Subnetwork
# -----------------------------------------
data "google_compute_network" "compute_network" {
  provider = google
  for_each = var.data_compute_networks

  name    = each.value.project != null ? each.value.name : var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  project = each.value.project
}

data "google_compute_subnetwork" "compute_subnetworks" {
  provider = google
  for_each = var.data_compute_subnetworks

  # name, project, and region are sufficient to look up the existing resource
  # The input map does not contain 'self_link', so it must be removed.
  name    = each.value.project != null ? each.value.name : var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  project = each.value.project
  region  = each.value.region
}

# -----------------------------------------
# Compute Routes
# -----------------------------------------
resource "google_compute_route" "compute_routes" {
  provider = google-beta
  for_each = var.compute_routes

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  dest_range  = each.value.dest_range
  network     = local.network_lookup[each.value.network].self_link
  description = try(each.value.description, null)
  priority    = try(each.value.priority, 1000)
  tags        = try(each.value.tags, null)

  next_hop_gateway       = try(each.value.next_hop_gateway, null)
  next_hop_ip            = try(each.value.next_hop_ip, null)
  next_hop_instance      = try(each.value.next_hop_instance_self_link, null)
  next_hop_instance_zone = try(each.value.next_hop_instance_zone, null)
  next_hop_ilb           = try(each.value.next_hop_ilb_self_link, null)

  project = each.value.project
}


# -----------------------------------------
# Policy-Based Routes
# -----------------------------------------
resource "google_network_connectivity_policy_based_route" "policy_routes" {
  provider = google-beta
  for_each = var.policy_based_routes

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  project     = each.value.project
  network     = local.network_lookup[each.value.network].id
  description = each.value.description
  priority    = each.value.priority

  next_hop_other_routes = each.value.use_default_routing ? "DEFAULT_ROUTING" : null
  next_hop_ilb_ip       = each.value.use_default_routing ? null : each.value.next_hop_ilb_ip

  filter {
    protocol_version = each.value.filter.protocol_version
    ip_protocol      = each.value.filter.ip_protocol
    dest_range       = each.value.filter.dest_range
    src_range        = each.value.filter.src_range
  }

  dynamic "virtual_machine" {
    for_each = each.value.target.tags != null ? [""] : []
    content {
      tags = each.value.target.tags
    }
  }

  dynamic "interconnect_attachment" {
    for_each = each.value.target.interconnect_attachment != null ? [""] : []
    content {
      region = each.value.target.interconnect_attachment
    }
  }
}

# -----------------------------------------
# Locals
# -----------------------------------------
# tflint-ignore: terraform_unused_declarations
locals {


  network_lookup = merge(
    { for k, v in google_compute_network.network : k => v },
    { for k, v in data.google_compute_network.compute_network : k => v }
  )
}
