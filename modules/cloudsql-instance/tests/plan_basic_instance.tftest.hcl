run "plan_basic_instance" {
  command = plan

  variables {
    resource_prefix = "test"
    default_labels = {
      managed_by = "terraform"
    }

    sql_database_instances = {
      "basic-instance" = {
        name             = "basic-instance"
        region           = "us-central1"
        database_version = "POSTGRES_14"
        project          = "test-project"
        settings = {
          tier = "db-f1-micro"
          user_labels = {
            env = "test"
          }
          database_flags          = []
          active_directory_config = []
          backup_configuration = {
            enabled = false
            backup_retention_settings = {
              retained_backups = 7
              retention_unit   = "COUNT"
            }
          }
          ip_configuration = {
            ipv4_enabled        = true
            authorized_networks = {}
          }
          location_preference = {}
          maintenance_window  = {}
          insights_config     = {}
        }
      }
    }
  }

  # Verify Instance
  assert {
    condition     = google_sql_database_instance.sql_database_instances["basic-instance"].name == "test-basic-instance"
    error_message = "Instance name incorrect"
  }

  assert {
    condition     = google_sql_database_instance.sql_database_instances["basic-instance"].database_version == "POSTGRES_14"
    error_message = "Database version incorrect"
  }

  # Verify Labels
  assert {
    condition     = google_sql_database_instance.sql_database_instances["basic-instance"].settings[0].user_labels["env"] == "test"
    error_message = "Should have user label env=test"
  }

  assert {
    condition     = google_sql_database_instance.sql_database_instances["basic-instance"].settings[0].user_labels["managed_by"] == "terraform"
    error_message = "Should have default label managed_by=terraform"
  }

  assert {
    condition     = google_sql_database_instance.sql_database_instances["basic-instance"].settings[0].user_labels["resourcetype"] == "sql-instance"
    error_message = "Should have automatic label resourcetype=sql-instance"
  }
}
