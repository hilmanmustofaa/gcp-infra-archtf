locals {
  _factory_egress_rules = coalesce(
    try(
      yamldecode(file(pathexpand(var.factories_config.egress_rules_file_path))),
    {}), tomap({})
  )
  _factory_ingress_rules = coalesce(
    try(
      yamldecode(file(pathexpand(var.factories_config.ingress_rules_file_path))),
    {}), tomap({})
  )
  factory_cidrs = coalesce(
    try(
      yamldecode(file(pathexpand(var.factories_config.cidr_file_path))),
    {}), {}
  )
  factory_egress_rules = {
    for k, v in local._factory_egress_rules : "egress/${k}" => {
      direction               = "EGRESS"
      name                    = k
      priority                = v.priority
      action                  = lookup(v, "action", "deny")
      description             = lookup(v, "description", null)
      disabled                = lookup(v, "disabled", false)
      enable_logging          = lookup(v, "enable_logging", null)
      security_profile_group  = lookup(v, "security_profile_group", null)
      target_resources        = lookup(v, "target_resources", null)
      target_service_accounts = lookup(v, "target_service_accounts", null)
      target_tags             = lookup(v, "target_tags", null)
      tls_inspect             = lookup(v, "tls_inspect", null)
      match = {
        address_groups       = lookup(v.match, "address_groups", null)
        fqdns                = lookup(v.match, "fqdns", null)
        region_codes         = lookup(v.match, "region_codes", null)
        threat_intelligences = lookup(v.match, "threat_intelligences", null)
        destination_ranges = (
          lookup(v.match, "destination_ranges", null) == null
          ? null
          : flatten([
            for r in v.match.destination_ranges :
            try(local.factory_cidrs[r], r)
          ])
        )
        source_ranges = (
          lookup(v.match, "source_ranges", null) == null
          ? null
          : flatten([
            for r in v.match.source_ranges :
            try(local.factory_cidrs[r], r)
          ])
        )
        source_tags = lookup(v.match, "source_tags", null)
        layer4_configs = (
          lookup(v.match, "layer4_configs", null) == null
          ? [{ protocol = "all", ports = null }]
          : [
            for c in v.match.layer4_configs :
            merge({ protocol = "all", ports = [] }, c)
          ]
        )
      }
    }
  }
  factory_ingress_rules = {
    for k, v in local._factory_ingress_rules : "ingress/${k}" => {
      direction               = "INGRESS"
      name                    = k
      priority                = v.priority
      action                  = lookup(v, "action", "allow")
      description             = lookup(v, "description", null)
      disabled                = lookup(v, "disabled", false)
      enable_logging          = lookup(v, "enable_logging", null)
      security_profile_group  = lookup(v, "security_profile_group", null)
      target_resources        = lookup(v, "target_resources", null)
      target_service_accounts = lookup(v, "target_service_accounts", null)
      target_tags             = lookup(v, "target_tags", null)
      tls_inspect             = lookup(v, "tls_inspect", null)
      match = {
        address_groups       = lookup(v.match, "address_groups", null)
        fqdns                = lookup(v.match, "fqdns", null)
        region_codes         = lookup(v.match, "region_codes", null)
        threat_intelligences = lookup(v.match, "threat_intelligences", null)
        destination_ranges = (
          lookup(v.match, "destination_ranges", null) == null
          ? null
          : flatten([
            for r in v.match.destination_ranges :
            try(local.factory_cidrs[r], r)
          ])
        )
        source_ranges = (
          lookup(v.match, "source_ranges", null) == null
          ? null
          : flatten([
            for r in v.match.source_ranges :
            try(local.factory_cidrs[r], r)
          ])
        )
        source_tags = lookup(v.match, "source_tags", null)
        layer4_configs = (
          lookup(v.match, "layer4_configs", null) == null
          ? [{ protocol = "all", ports = null }]
          : [
            for c in v.match.layer4_configs :
            merge({ protocol = "all", ports = [] }, c)
          ]
        )
      }
    }
  }
}
