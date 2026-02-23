locals {
  network_lookup = var.network_lookup

  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "sqladmin.googleapis.com/Instance"
    gcp_service    = "sqladmin.googleapis.com"
    tf_module      = "cloudsql-instance"
    tf_layer       = "data"
    tf_resource    = "instance"
  }
}

resource "google_sql_database_instance" "sql_database_instances" {
  provider = google-beta
  for_each = var.sql_database_instances

  name                 = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  region               = each.value.region
  database_version     = each.value.database_version
  master_instance_name = each.value.master_instance_name
  project              = each.value.project
  root_password        = each.value.root_password != null ? random_password.passwords[each.value.root_password].result : null
  encryption_key_name  = each.value.encryption_key_name
  deletion_protection  = each.value.deletion_protection

  settings {
    tier                        = each.value.settings.tier
    activation_policy           = each.value.settings.activation_policy
    availability_type           = each.value.settings.availability_type
    collation                   = each.value.settings.collation
    disk_autoresize             = each.value.settings.disk_autoresize
    disk_size                   = each.value.settings.disk_size
    disk_type                   = each.value.settings.disk_type
    pricing_plan                = each.value.settings.pricing_plan
    deletion_protection_enabled = each.value.settings.deletion_protection_enabled
    user_labels = merge(
      local.finops_labels_default,
      var.default_labels,
      each.value.settings.user_labels,
      { "resourcetype" = "sql-instance" }
    )

    dynamic "database_flags" {
      for_each = each.value.settings.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "active_directory_config" {
      for_each = each.value.settings.active_directory_config
      content {
        domain = active_directory_config.value.domain
      }
    }

    dynamic "backup_configuration" {
      for_each = each.value.settings.backup_configuration.enabled ? { "enabled" = each.value.settings.backup_configuration } : {}
      content {
        binary_log_enabled             = each.value.settings.backup_configuration.binary_log_enabled
        enabled                        = each.value.settings.backup_configuration.enabled
        start_time                     = each.value.settings.backup_configuration.start_time
        point_in_time_recovery_enabled = each.value.settings.backup_configuration.point_in_time_recovery_enabled
        location                       = each.value.settings.backup_configuration.location
        transaction_log_retention_days = each.value.settings.backup_configuration.transaction_log_retention_days
        backup_retention_settings {
          retained_backups = each.value.settings.backup_configuration.backup_retention_settings.retained_backups
          retention_unit   = each.value.settings.backup_configuration.backup_retention_settings.retention_unit
        }
      }
    }

    ip_configuration {
      ipv4_enabled       = each.value.settings.ip_configuration.ipv4_enabled
      private_network    = each.value.settings.ip_configuration.private_network != null ? try(local.network_lookup[each.value.settings.ip_configuration.private_network].id, null) : null
      allocated_ip_range = each.value.settings.ip_configuration.allocated_ip_range

      dynamic "authorized_networks" {
        for_each = length(each.value.settings.ip_configuration.authorized_networks) > 0 ? each.value.settings.ip_configuration.authorized_networks : {}
        content {
          expiration_time = authorized_networks.value.expiration_time
          name            = authorized_networks.value.name
          value           = authorized_networks.value.value
        }
      }
    }

    dynamic "location_preference" {
      for_each = length(each.value.settings.location_preference) > 0 ? { "enabled" = each.value.settings.location_preference } : {}
      content {
        follow_gae_application = each.value.settings.location_preference.follow_gae_application
        zone                   = each.value.settings.location_preference.zone
      }
    }

    dynamic "maintenance_window" {
      for_each = length(each.value.settings.maintenance_window) > 0 ? { "enabled" = each.value.settings.maintenance_window } : {}
      content {
        day          = each.value.settings.maintenance_window.day
        hour         = each.value.settings.maintenance_window.hour
        update_track = each.value.settings.maintenance_window.update_track
      }
    }

    dynamic "insights_config" {
      for_each = length(each.value.settings.insights_config) > 0 ? { "enabled" = each.value.settings.insights_config } : {}
      content {
        query_insights_enabled  = each.value.settings.insights_config.query_insights_enabled
        query_string_length     = each.value.settings.insights_config.query_string_length
        record_application_tags = each.value.settings.insights_config.record_application_tags
        record_client_address   = each.value.settings.insights_config.record_client_address
      }
    }
  }

  lifecycle {
    ignore_changes = [
      settings[0].activation_policy,
      settings[0].disk_size,
      settings[0].database_flags,
      settings[0].insights_config,
      settings[0].maintenance_window,
      settings[0].deny_maintenance_period,
      settings[0].backup_configuration,
      settings[0].collation,
      settings[0].time_zone,
      settings[0].active_directory_config,
      settings[0].advanced_machine_features,
      settings[0].sql_server_audit_config,
      root_password,
      deletion_protection
    ]
  }
}

resource "random_password" "passwords" {
  for_each = toset([
    for k, v in var.sql_users : k if v.password == null
  ])
  length  = 16
  special = true
}

resource "google_sql_database" "sql_databases" {
  provider = google-beta
  for_each = var.sql_databases

  name      = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  instance  = [for k, v in google_sql_database_instance.sql_database_instances : v.name if k == each.value.instance][0]
  charset   = each.value.charset
  collation = each.value.collation
  project   = each.value.project
}

resource "google_sql_user" "sql_users" {
  provider = google-beta
  for_each = var.sql_users

  name            = var.resource_prefix != null ? join(var.join_separator, [var.resource_prefix, each.value.name]) : each.value.name
  instance        = [for k, v in google_sql_database_instance.sql_database_instances : v.name if k == each.value.instance][0]
  password        = each.value.password != null ? each.value.password : try(random_password.passwords[each.key].result, null)
  type            = each.value.type
  deletion_policy = each.value.deletion_policy
  host            = each.value.host
  project         = each.value.project
}
