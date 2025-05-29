resource "google_sql_database_instance" "instances" {
  for_each = { for db in var.databases : db.name => db }

  name             = each.value.name
  database_version = "${upper(each.value.type)}_${each.value.version}"
  region           = var.region

  settings {
    tier              = "db-g1-${each.value.size}"
    availability_type = length(each.value.zone) > 1 ? "REGIONAL" : "ZONAL"

    ip_configuration {
      ipv4_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "databases" {
  for_each = { for db in var.databases : db.name => db }

  name     = each.value.name
  instance = google_sql_database_instance.instances[each.value.name].name
}

# Create default user for each database
resource "google_sql_user" "users" {
  for_each = { for db in var.databases : db.name => db }

  name        = var.db_username
  instance    = google_sql_database_instance.instances[each.value.name].name
  password_wo = var.db_pass
}

