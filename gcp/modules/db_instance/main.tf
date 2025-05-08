locals {
}

resource "google_sql_database_instance" "instances" {
  for_each = { for db in var.databases : db.name => db }

  name             = each.value.name
  database_version = "${upper(each.value.type)}_${each.value.version}"
  region           = var.region

  settings {
    tier = "db-g1-${each.value.size}"
    availability_type = length(each.value.zone) > 1 ? "REGIONAL" : "ZONAL"

    ip_configuration {
      # Use public IPs instead of private IPs to avoid Service Networking API requirement
      ipv4_enabled    = true
      # Comment out private_network to avoid using Service Networking API
      # private_network = var.private_networks[each.value.network]
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "databases" {
  for_each = { for db in var.databases : db.name => db }

  name     = each.value.name
  instance = google_sql_database_instance.instances[each.value.name].name
}

# # Create default user for each database
# resource "google_sql_user" "users" {
#   for_each = { for db in var.databases : db.name => db }
  
#   name     = "dbuser"
#   instance = google_sql_database_instance.instances[each.value.name].name
#   password = "strongpassword123" # In production, use a proper secret management solution
# }

