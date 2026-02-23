locals {
  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "dns.googleapis.com/ManagedZone"
    gcp_service    = "dns.googleapis.com"
    tf_module      = "dns"
    tf_layer       = "networking"
    tf_resource    = "managed-zone"
  }

  dns_policies_config = {
    for key, policy in var.dns_policies : key => {
      name                      = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, policy.name]) : policy.name
      description               = policy.description
      project                   = try(policy.project, var.project_id)
      enable_inbound_forwarding = policy.enable_inbound_forwarding
      enable_logging            = policy.enable_logging

      alternative_name_server_config = length(policy.alternative_name_server_config.target_name_servers) > 0 ? {
        target_name_servers = [
          for server in policy.alternative_name_server_config.target_name_servers : {
            ipv4_address    = server.ipv4_address
            forwarding_path = server.forwarding_path
          }
        ]
      } : null

      networks = [
        for network in policy.networks : {
          network_url = try(var.network_lookup[network].self_link, null)
        }
      ]
    }
  }

  dns_managed_zones_config = {
    for key, zone in var.dns_managed_zones : key => {
      name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, zone.name]) : zone.name
      dns_name    = zone.dns_name
      description = zone.description
      visibility  = zone.visibility
      project     = try(zone.project, var.project_id)
      labels      = merge(local.finops_labels_default, var.default_labels, zone.labels, { "resourcetype" = "dns-managed-zone" })

      dnssec_config = try(length(zone.dnssec_config), 0) > 0 && zone.visibility == "public" ? {
        kind          = zone.dnssec_config.kind
        non_existence = zone.dnssec_config.non_existence
        state         = zone.dnssec_config.state
        default_key_specs = length(zone.dnssec_config.default_key_specs) > 0 ? [
          for key_spec in zone.dnssec_config.default_key_specs : {
            algorithm  = key_spec.algorithm
            key_length = key_spec.key_length
            key_type   = key_spec.key_type
            kind       = key_spec.kind
          }
        ] : []
      } : null

      private_visibility_config = try(length(zone.private_visibility_config.networks), 0) > 0 ? {
        networks = [
          for network in zone.private_visibility_config.networks : {
            network_url = try(var.network_lookup[network].self_link, null)
          }
        ]
      } : null

      forwarding_config = try(length(zone.forwarding_config.target_name_servers), 0) > 0 ? {
        target_name_servers = [
          for server in zone.forwarding_config.target_name_servers : {
            ipv4_address    = server.ipv4_address
            forwarding_path = server.forwarding_path
          }
        ]
      } : null

      peering_config = try(length(zone.peering_config.target_network), 0) > 0 ? {
        target_network = [
          for network in zone.peering_config.target_network : {
            network_url = try(var.network_lookup[network].self_link, null)
          }
        ]
      } : null
    }
  }

  dns_record_sets_config = {
    for key, record in var.dns_record_sets : key => {
      managed_zone = [for k, v in merge(google_dns_managed_zone.dns_managed_zones, data.google_dns_managed_zone.dns_managed_zones) : v.name if k == record.managed_zone][0]
      name         = record.name != null ? join(".", [record.name, [for k, v in merge(google_dns_managed_zone.dns_managed_zones, data.google_dns_managed_zone.dns_managed_zones) : v.dns_name if k == record.managed_zone][0]]) : [for k, v in merge(google_dns_managed_zone.dns_managed_zones, data.google_dns_managed_zone.dns_managed_zones) : v.dns_name if k == record.managed_zone][0]
      type         = record.type
      ttl          = record.ttl
      rrdatas      = record.rrdatas
      project      = try(record.project, var.project_id)

      routing_policy = (try(length(record.routing_policy.wrr), 0) > 0 || try(length(record.routing_policy.geo), 0) > 0) ? {
        wrr = [
          for policy in record.routing_policy.wrr : {
            weight  = policy.weight
            rrdatas = policy.rrdatas
          }
        ]
        geo = [
          for policy in record.routing_policy.geo : {
            location = policy.location
            rrdatas  = policy.rrdatas
          }
        ]
      } : null
    }
  }
}

# DNS POLICY
resource "google_dns_policy" "dns_policies" {
  provider = google
  for_each = local.dns_policies_config

  name                      = each.value.name
  description               = each.value.description
  project                   = each.value.project
  enable_inbound_forwarding = each.value.enable_inbound_forwarding
  enable_logging            = each.value.enable_logging

  dynamic "alternative_name_server_config" {
    for_each = each.value.alternative_name_server_config != null ? [each.value.alternative_name_server_config] : []
    content {
      dynamic "target_name_servers" {
        for_each = alternative_name_server_config.value.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = target_name_servers.value.forwarding_path
        }
      }
    }
  }

  dynamic "networks" {
    for_each = each.value.networks
    content {
      network_url = networks.value.network_url
    }
  }
}

# DATA ZONE IMPORT
data "google_dns_managed_zone" "dns_managed_zones" {
  provider = google
  for_each = var.data_dns_managed_zones

  name    = each.value.project != null ? each.value.name : var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  project = each.value.project
}

# MANAGED ZONE RESOURCE
resource "google_dns_managed_zone" "dns_managed_zones" {
  provider = google-beta
  for_each = local.dns_managed_zones_config

  name        = each.value.name
  dns_name    = each.value.dns_name
  description = each.value.description
  project     = each.value.project
  labels      = each.value.labels
  visibility  = each.value.visibility

  dynamic "dnssec_config" {
    for_each = each.value.dnssec_config != null ? [each.value.dnssec_config] : []
    content {
      kind          = dnssec_config.value.kind
      non_existence = dnssec_config.value.non_existence
      state         = dnssec_config.value.state

      dynamic "default_key_specs" {
        for_each = dnssec_config.value.default_key_specs
        content {
          algorithm  = default_key_specs.value.algorithm
          key_length = default_key_specs.value.key_length
          key_type   = default_key_specs.value.key_type
          kind       = default_key_specs.value.kind
        }
      }
    }
  }

  dynamic "private_visibility_config" {
    for_each = each.value.private_visibility_config != null ? [each.value.private_visibility_config] : []
    content {
      dynamic "networks" {
        for_each = private_visibility_config.value.networks
        content {
          network_url = networks.value.network_url
        }
      }
    }
  }

  dynamic "forwarding_config" {
    for_each = each.value.forwarding_config != null ? [each.value.forwarding_config] : []
    content {
      dynamic "target_name_servers" {
        for_each = forwarding_config.value.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = target_name_servers.value.forwarding_path
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = each.value.peering_config != null ? [each.value.peering_config] : []
    content {
      dynamic "target_network" {
        for_each = peering_config.value.target_network
        content {
          network_url = target_network.value.network_url
        }
      }
    }
  }
}

# RECORD SETS
resource "google_dns_record_set" "dns_record_sets" {
  provider = google
  for_each = local.dns_record_sets_config

  managed_zone = each.value.managed_zone
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
  project      = each.value.project

  dynamic "routing_policy" {
    for_each = each.value.routing_policy != null ? [each.value.routing_policy] : []
    content {
      dynamic "wrr" {
        for_each = routing_policy.value.wrr
        content {
          weight  = wrr.value.weight
          rrdatas = wrr.value.rrdatas
        }
      }
      dynamic "geo" {
        for_each = routing_policy.value.geo
        content {
          location = geo.value.location
          rrdatas  = geo.value.rrdatas
        }
      }
    }
  }
}
