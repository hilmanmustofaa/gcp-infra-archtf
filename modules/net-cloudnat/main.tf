resource "google_compute_router_nat" "compute_router_nats" {
  provider = google-beta
  for_each = var.compute_router_nats

  name    = var.resource_prefix != null ? join("-", [var.resource_prefix, each.value.name]) : each.value.name
  project = each.value.project
  region  = each.value.region
  router  = var.router_lookup[each.value.router].name
  type    = each.value.type

  nat_ip_allocate_option = each.value.nat_ip_allocate_option
  nat_ips                = [for k in each.value.nat_ips : var.nat_ip_lookup[k].self_link]

  source_subnetwork_ip_ranges_to_nat = each.value.source_subnetwork_ip_ranges_to_nat

  dynamic "subnetwork" {
    for_each = each.value.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS" ? each.value.subnetwork : {}

    content {
      name                     = var.network_lookup[subnetwork.value.name].self_link
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = subnetwork.value.secondary_ip_range_names
    }
  }

  min_ports_per_vm                    = each.value.min_ports_per_vm
  max_ports_per_vm                    = try(each.value.max_ports_per_vm, null)
  enable_dynamic_port_allocation      = each.value.enable_dynamic_port_allocation
  enable_endpoint_independent_mapping = each.value.enable_endpoint_independent_mapping

  udp_idle_timeout_sec             = each.value.udp_idle_timeout_sec
  icmp_idle_timeout_sec            = each.value.icmp_idle_timeout_sec
  tcp_established_idle_timeout_sec = each.value.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec  = each.value.tcp_transitory_idle_timeout_sec
  tcp_time_wait_timeout_sec        = try(each.value.tcp_time_wait_timeout_sec, null)

  dynamic "log_config" {
    for_each = each.value.log_config.enable ? { "log_config" = each.value.log_config } : {}

    content {
      enable = each.value.log_config.enable
      filter = each.value.log_config.filter
    }
  }

  endpoint_types = try(each.value.endpoint_types, null)

  dynamic "rules" {
    for_each = each.value.rules != null ? each.value.rules : {}

    content {
      rule_number = tonumber(rules.key)
      description = rules.value.description
      match       = rules.value.match
      action {
        source_nat_active_ips = try(rules.value.action.source_nat_active_ips, [])
        source_nat_drain_ips  = try(rules.value.action.source_nat_drain_ips, [])
      }
    }
  }
}
