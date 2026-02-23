locals {
  _custom_constraints_factory_data_raw = merge([
    for f in try(fileset(var.factories_config.org_policy_custom_constraints, "*.yaml"), []) :
    yamldecode(file("${var.factories_config.org_policy_custom_constraints}/${f}"))
  ]...)
  _custom_constraints_factory_data = {
    for k, v in local._custom_constraints_factory_data_raw :
    k => {
      display_name   = try(v.display_name, null)
      description    = try(v.description, null)
      action_type    = v.action_type
      condition      = v.condition
      method_types   = v.method_types
      resource_types = v.resource_types
    }
  }
  _custom_constraints = merge(
    local._custom_constraints_factory_data,
    var.org_policy_custom_constraints
  )
  custom_constraints = {
    for k, v in local._custom_constraints :
    k => merge(v, {
      name   = k
      parent = var.organization_id
    })
  }
}

resource "google_org_policy_custom_constraint" "constraint" {
  provider = google-beta

  for_each       = local.custom_constraints
  name           = each.value.name
  parent         = each.value.parent
  display_name   = each.value.display_name
  description    = each.value.description
  action_type    = each.value.action_type
  condition      = each.value.condition
  method_types   = each.value.method_types
  resource_types = each.value.resource_types
}
