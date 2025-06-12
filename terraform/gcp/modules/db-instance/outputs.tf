output "instance_connection_names" {
  value = { for k, v in google_sql_database_instance.instances : k => v.connection_name }
}

output "database_names" {
  value = { for k, v in google_sql_database.databases : k => v.name }
}

output "db_hosts" {
  description = "Map of database name to hostname"
  value       = { for db_name, db in google_sql_database_instance.instances : db_name => db.private_ip_address }
}

output "db_users" {
  description = "Map of database name to username"
  value       = { for db_name, _ in google_sql_database_instance.instances : db_name => var.db_username }
}

output "db_passwords" {
  description = "Map of database name to password"
  value       = { for db_name, _ in google_sql_database_instance.instances : db_name => var.db_pass }
  sensitive   = true
}

output "db_ports" {
  description = "Map of database name to port"
  value       = { for db_name, _ in google_sql_database_instance.instances : db_name => "5432" }
}

output "db_names" {
  description = "Map of database name to database name"
  value       = { for db_name, db in google_sql_database.databases : db_name => db.name }
}