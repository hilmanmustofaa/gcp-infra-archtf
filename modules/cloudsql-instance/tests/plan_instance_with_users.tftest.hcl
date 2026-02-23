run "plan_instance_with_users" {
  command = plan

  variables {
    resource_prefix = "test"

    sql_database_instances = {
      "user-instance" = {
        name             = "user-instance"
        region           = "us-central1"
        database_version = "MYSQL_8_0"
        project          = "test-project"
        settings = {
          tier                    = "db-n1-standard-1"
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

    sql_databases = {
      "app-db" = {
        name     = "app-db"
        instance = "user-instance"
        project  = "test-project"
      }
    }

    sql_users = {
      "app-user" = {
        name     = "app-user"
        instance = "user-instance"
        project  = "test-project"
        password = "secret-password"
      }
    }
  }

  # Verify Instance
  assert {
    condition     = google_sql_database_instance.sql_database_instances["user-instance"].database_version == "MYSQL_8_0"
    error_message = "Database version incorrect"
  }

  # Verify Database
  assert {
    condition     = google_sql_database.sql_databases["app-db"].name == "test-app-db"
    error_message = "Database name incorrect"
  }

  # Verify User
  assert {
    condition     = google_sql_user.sql_users["app-user"].name == "test-app-user"
    error_message = "User name incorrect"
  }
}
