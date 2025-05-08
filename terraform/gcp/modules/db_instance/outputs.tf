output "instance_connection_names" {
  value = { for k, v in google_sql_database_instance.instances : k => v.connection_name }
}

output "database_names" {
  value = { for k, v in google_sql_database.databases : k => v.name }
}
