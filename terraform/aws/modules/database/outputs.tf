output "check_secret_exists_all" {
  value = {
    for id, check in data.external.check_secret_exists :
    id => check.result
  }
}

output "db_hosts" {
  description = "Map of database name to hostname"
  value       = { for db_name, db in aws_db_instance.database : db_name => db.address }
}

output "db_users" {
  description = "Map of database name to username"
  value       = { for db_name, db in aws_db_instance.database : db_name => db.username }
}

output "db_passwords" {
  description = "Map of database name to password"
  value       = { for db_name, pass in random_password.db_password : db_name => pass.result }
  sensitive   = true
}

output "db_ports" {
  description = "Map of database name to port"
  value       = { for db_name, db in aws_db_instance.database : db_name => db.port }
}

output "db_names" {
  description = "Map of database name to database name"
  value       = { for db_name, db in aws_db_instance.database : db_name => db.db_name }
}