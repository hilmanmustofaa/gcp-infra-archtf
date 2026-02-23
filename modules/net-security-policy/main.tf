resource "google_compute_security_policy" "compute_security_policies" {
  provider = google-beta
  for_each = var.compute_security_policies

  name        = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  description = each.value.description
  project     = each.value.project
  type        = each.value.type



  dynamic "rule" {
    for_each = each.value.rule

    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      preview     = rule.value.preview

      match {
        dynamic "config" {
          for_each = length(rule.value.match.config.src_ip_ranges) > 0 ? { "src_ip_ranges" = rule.value.match.config.src_ip_ranges } : {}
          content {
            src_ip_ranges = rule.value.match.config.src_ip_ranges
          }
        }
        versioned_expr = rule.value.match.versioned_expr
        dynamic "expr" {
          for_each = rule.value.match.expr.expression != null ? { "expression" = rule.value.match.expr.expression } : {}
          content {
            expression = rule.value.match.expr.expression
          }
        }
      }

      dynamic "rate_limit_options" {
        for_each = length(rule.value.rate_limit_options) > 0 ? { "rate_limit_options" = rule.value.rate_limit_options } : {}
        content {
          ban_duration_sec = rate_limit_options.value.ban_duration_sec
          ban_threshold {
            count        = rate_limit_options.value.ban_threshold.count
            interval_sec = rate_limit_options.value.ban_threshold.interval_sec
          }
          conform_action      = rate_limit_options.value.conform_action
          enforce_on_key      = rate_limit_options.value.enforce_on_key
          enforce_on_key_name = rate_limit_options.value.enforce_on_key_name
          exceed_action       = rate_limit_options.value.exceed_action
          rate_limit_threshold {
            count        = rate_limit_options.value.rate_limit_threshold.count
            interval_sec = rate_limit_options.value.rate_limit_threshold.interval_sec
          }
        }
      }

      dynamic "redirect_options" {
        for_each = length(rule.value.redirect_options) > 0 ? { "redirect_options" = rule.value.redirect_options } : {}
        content {
          type   = redirect_options.value.type
          target = redirect_options.value.target
        }
      }
    }
  }

  dynamic "advanced_options_config" {
    for_each = each.value.advanced_options_config != null ? { "advanced_options_config" = each.value.advanced_options_config } : {}
    content {
      json_parsing = advanced_options_config.value.json_parsing
      log_level    = advanced_options_config.value.log_level
    }
  }

  dynamic "adaptive_protection_config" {
    for_each = each.value.adaptive_protection_config != null ? { "adaptive_protection_config" = each.value.adaptive_protection_config } : {}
    content {
      layer_7_ddos_defense_config {
        enable          = adaptive_protection_config.value.layer_7_ddos_defense_config.enable
        rule_visibility = adaptive_protection_config.value.layer_7_ddos_defense_config.rule_visibility
      }
    }
  }
}
