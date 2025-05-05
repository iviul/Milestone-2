output "instance_connection_name" {
  description = "The connection name of the PostgreSQL instance"
  value       = google_sql_database_instance.postgres_instance.connection_name
}

output "database_name" {
  description = "The name of the PostgreSQL database"
  value       = google_sql_database.postgres_db.name
}
