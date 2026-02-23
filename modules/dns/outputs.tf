output "dns_managed_zones" {
  description = "Map of created DNS managed zones."
  value = {
    for k, v in google_dns_managed_zone.dns_managed_zones : k => {
      id           = v.id
      name         = v.name
      dns_name     = v.dns_name
      name_servers = v.name_servers
      visibility   = v.visibility
      labels       = v.labels
    }
  }
}

output "dns_managed_zones_map" {
  description = "Map of created and imported DNS managed zones."
  value = merge(
    {
      for k, v in google_dns_managed_zone.dns_managed_zones : k => {
        id           = v.id
        name         = v.name
        dns_name     = v.dns_name
        name_servers = v.name_servers
      }
    },
    {
      for k, v in data.google_dns_managed_zone.dns_managed_zones : k => {
        id           = v.id
        name         = v.name
        dns_name     = v.dns_name
        name_servers = v.name_servers
      }
    }
  )
}

output "dns_policies" {
  description = "Map of created DNS policies."
  value = {
    for k, v in google_dns_policy.dns_policies : k => {
      id                        = v.id
      name                      = v.name
      enable_inbound_forwarding = v.enable_inbound_forwarding
      enable_logging            = v.enable_logging
    }
  }
}

output "dns_policies_ids" {
  description = "Map of DNS policy names to their IDs."
  value = {
    for k, v in google_dns_policy.dns_policies : k => v.id
  }
}

output "dns_record_sets" {
  description = "Map of created DNS record sets."
  value = {
    for k, v in google_dns_record_set.dns_record_sets : k => {
      id           = v.id
      name         = v.name
      type         = v.type
      ttl          = v.ttl
      managed_zone = v.managed_zone
      rrdatas      = v.rrdatas
    }
  }
}

output "name_servers" {
  description = "Map of zone names to list of name servers."
  value = {
    for k, v in google_dns_managed_zone.dns_managed_zones : k => v.name_servers
  }
}