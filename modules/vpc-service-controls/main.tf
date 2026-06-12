locals {
  # ===== FinOps labels (org-scoped resources carry no labels; exposed as output only). =====
  finops_labels_default = {
    gcp_asset_type = "accesscontextmanager-googleapis-com--serviceperimeter"
    gcp_service    = "accesscontextmanager-googleapis-com"
    tf_module      = "vpc-service-controls"
    tf_layer       = "security"
    tf_resource    = "service-perimeter"
  }

  finops_labels = merge(
    local.finops_labels_default,
    var.default_labels,
  )

  policy_name = var.create_access_policy != null ? google_access_context_manager_access_policy.policy[0].name : var.access_policy_id

  # Deterministic full names (computed without referencing the resources to avoid cycles).
  access_level_names = { for k, v in var.access_levels : k => "${local.policy_name}/accessLevels/${k}" }

  # Resolve an access-level reference: a logical key in this module, else a literal full name.
  resolve_level = { for k in distinct(flatten([
    for p in values(var.service_perimeters) : concat(
      p.access_levels,
      flatten([for ip in p.ingress_policies : [for s in ip.from.sources : s.access_level if s.access_level != null]]),
    )
  ])) : k => contains(keys(local.access_level_names), k) ? local.access_level_names[k] : k }
}

resource "google_access_context_manager_access_policy" "policy" {
  count = var.create_access_policy != null ? 1 : 0

  parent = var.create_access_policy.parent
  title  = var.create_access_policy.title
}

resource "google_access_context_manager_access_level" "levels" {
  for_each = var.access_levels

  parent = local.policy_name
  name   = local.access_level_names[each.key]
  title  = each.value.title

  basic {
    combining_function = each.value.combining_function

    dynamic "conditions" {
      for_each = each.value.conditions
      content {
        ip_subnetworks         = conditions.value.ip_subnetworks
        required_access_levels = conditions.value.required_access_levels
        members                = conditions.value.members
        regions                = conditions.value.regions
        negate                 = conditions.value.negate
      }
    }
  }
}

resource "google_access_context_manager_service_perimeter" "perimeters" {
  for_each = var.service_perimeters

  parent         = local.policy_name
  name           = "${local.policy_name}/servicePerimeters/${each.key}"
  title          = each.value.title
  description    = each.value.description
  perimeter_type = each.value.perimeter_type

  status {
    resources           = each.value.resources
    restricted_services = each.value.restricted_services
    access_levels       = [for l in each.value.access_levels : local.resolve_level[l]]

    dynamic "vpc_accessible_services" {
      for_each = each.value.vpc_accessible_services != null ? [each.value.vpc_accessible_services] : []
      content {
        enable_restriction = vpc_accessible_services.value.enable_restriction
        allowed_services   = vpc_accessible_services.value.allowed_services
      }
    }

    dynamic "ingress_policies" {
      for_each = each.value.ingress_policies
      content {
        ingress_from {
          identity_type = ingress_policies.value.from.identity_type
          identities    = ingress_policies.value.from.identities

          dynamic "sources" {
            for_each = ingress_policies.value.from.sources
            content {
              access_level = sources.value.access_level != null ? local.resolve_level[sources.value.access_level] : null
              resource     = sources.value.resource
            }
          }
        }
        ingress_to {
          resources = ingress_policies.value.to.resources
          dynamic "operations" {
            for_each = ingress_policies.value.to.operations
            content {
              service_name = operations.value.service_name
              dynamic "method_selectors" {
                for_each = operations.value.methods
                content {
                  method = method_selectors.value
                }
              }
            }
          }
        }
      }
    }

    dynamic "egress_policies" {
      for_each = each.value.egress_policies
      content {
        egress_from {
          identity_type = egress_policies.value.from.identity_type
          identities    = egress_policies.value.from.identities
        }
        egress_to {
          resources          = egress_policies.value.to.resources
          external_resources = egress_policies.value.to.external_resources
          dynamic "operations" {
            for_each = egress_policies.value.to.operations
            content {
              service_name = operations.value.service_name
              dynamic "method_selectors" {
                for_each = operations.value.methods
                content {
                  method = method_selectors.value
                }
              }
            }
          }
        }
      }
    }
  }

  # Access levels must exist before the perimeter references them.
  depends_on = [google_access_context_manager_access_level.levels]
}
