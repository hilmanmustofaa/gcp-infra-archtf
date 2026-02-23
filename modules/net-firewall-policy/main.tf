locals {
  _rules_egress = {
    for name, rule in merge(var.egress_rules) :
    "egress/${name}" => merge(rule, { name = name, direction = "EGRESS" })
  }
  _rules_ingress = {
    for name, rule in merge(var.ingress_rules) :
    "ingress/${name}" => merge(rule, { name = name, direction = "INGRESS" })
  }
  rules = merge(
    local.factory_egress_rules, local.factory_ingress_rules,
    local._rules_egress, local._rules_ingress
  )
  # do not depend on the parent id as that might be dynamic and prevent count
  use_hierarchical = var.region == null
  use_regional     = !local.use_hierarchical && var.region != "global"
}
