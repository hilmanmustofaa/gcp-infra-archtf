output "databases" {
  description = "The created Cloud SQL databases."
  value       = google_sql_database.sql_databases
}

output "instances" {
  description = "The created Cloud SQL instances."
  value       = google_sql_database_instance.sql_database_instances
  sensitive   = true
}

output "users" {
  description = "The created Cloud SQL users."
  value       = google_sql_user.sql_users
  sensitive   = true
}
