locals {
  name_base = {
    for k, v in var.external_addresses : k => v.name != null ? v.name : k
  }
  external_addresses = {
    for k, v in var.external_addresses : k => merge(v, {
      name = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, local.name_base[k]]) : local.name_base[k]
    })
  }

  internal_name_base = {
    for k, v in var.internal_addresses : k => v.name != null ? v.name : k
  }
  internal_addresses = {
    for k, v in var.internal_addresses : k => merge(v, {
      name = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, local.internal_name_base[k]]) : local.internal_name_base[k]
    })
  }

  global_name_base = {
    for k, v in var.global_addresses : k => v.name != null ? v.name : k
  }
  global_addresses = {
    for k, v in var.global_addresses : k => merge(v, {
      name = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, local.global_name_base[k]]) : local.global_name_base[k]
    })
  }

  psa_name_base = {
    for k, v in var.psa_addresses : k => v.name != null ? v.name : k
  }
  psa_addresses = {
    for k, v in var.psa_addresses : k => merge(v, {
      name = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, local.psa_name_base[k]]) : local.psa_name_base[k]
    })
  }

  ipsec_name_base = {
    for k, v in var.ipsec_interconnect_addresses : k => v.name != null ? v.name : k
  }
  ipsec_interconnect_addresses = {
    for k, v in var.ipsec_interconnect_addresses : k => merge(v, {
      name = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, local.ipsec_name_base[k]]) : local.ipsec_name_base[k]
    })
  }
}

resource "google_compute_address" "compute_addresses" {
  provider     = google-beta
  for_each     = local.external_addresses
  project      = var.project_id
  name         = each.value.name
  region       = each.value.region
  address      = try(each.value.address, null)
  address_type = "EXTERNAL"
  description  = try(each.value.description, null)
  labels       = merge(var.default_labels, try(each.value.labels, {}))
  network_tier = try(each.value.network_tier, "PREMIUM")
  subnetwork   = try(each.value.subnetwork, null)
}

resource "google_compute_address" "internal_addresses" {
  provider     = google-beta
  for_each     = local.internal_addresses
  project      = var.project_id
  name         = each.value.name
  address      = try(each.value.address, null)
  address_type = "INTERNAL"
  description  = try(each.value.description, null)
  region       = each.value.region
  subnetwork   = each.value.subnetwork
  labels       = merge(var.default_labels, try(each.value.labels, {}))
  purpose      = try(each.value.purpose, null)
}

resource "google_compute_global_address" "global_addresses" {
  provider    = google-beta
  for_each    = local.global_addresses
  project     = var.project_id
  name        = each.value.name
  description = try(each.value.description, null)
  ip_version  = try(each.value.ip_version, "IPV4")
  labels      = merge(var.default_labels, try(each.value.labels, {}))
}

resource "google_compute_global_address" "psa_addresses" {
  provider      = google-beta
  for_each      = local.psa_addresses
  project       = var.project_id
  name          = each.value.name
  description   = try(each.value.description, null)
  address       = each.value.address
  address_type  = "INTERNAL"
  network       = each.value.network
  prefix_length = each.value.prefix_length
  purpose       = "VPC_PEERING"
  labels        = merge(var.default_labels, try(each.value.labels, {}))
}

resource "google_compute_address" "ipsec_interconnect_addresses" {
  provider      = google-beta
  for_each      = local.ipsec_interconnect_addresses
  project       = var.project_id
  name          = each.value.name
  description   = try(each.value.description, null)
  address       = each.value.address
  address_type  = "INTERNAL"
  region        = each.value.region
  network       = each.value.network
  prefix_length = each.value.prefix_length
  purpose       = "IPSEC_INTERCONNECT"
  labels        = merge(var.default_labels, try(each.value.labels, {}))
}
