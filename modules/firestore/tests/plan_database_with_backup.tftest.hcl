run "plan_database_with_backup" {
  command = plan

  variables {
    project_id = "test-project"

    database = {
      name        = "backup-db"
      location_id = "us-east1"
      type        = "DATASTORE_MODE"
    }

    backup_schedule = {
      retention        = "86400s" # 1 day
      daily_recurrence = true
    }
  }

  # Verify Database
  assert {
    condition     = google_firestore_database.firestore_database[0].name == "backup-db"
    error_message = "Database name incorrect"
  }

  assert {
    condition     = google_firestore_database.firestore_database[0].type == "DATASTORE_MODE"
    error_message = "Database type incorrect"
  }

  # Verify Backup Schedule
  assert {
    condition     = google_firestore_backup_schedule.firestore_backup_schedule[0].retention == "86400s"
    error_message = "Backup retention incorrect"
  }

  assert {
    condition     = length(google_firestore_backup_schedule.firestore_backup_schedule[0].daily_recurrence) == 1
    error_message = "Daily recurrence should be enabled"
  }
}
