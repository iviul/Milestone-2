resource "google_sql_database_instance" "instances" {
  for_each = { for db in var.databases : db.db_name => db }

  name             = each.key
  database_version = each.value.database_version
  region           = each.value.region

  settings {
    tier = each.value.tier

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.private_networks[each.value.private_network]
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "databases" {
  for_each = { for db in var.databases : db.db_name => db }

  name     = each.value.db_name
  instance = google_sql_database_instance.instances[each.key].name
}

