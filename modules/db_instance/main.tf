resource "google_sql_database_instance" "postgres_instance" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.private_network
    }
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_database_instance" "mysql_instance" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.private_network
    }
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "postgres_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_database" "mysql_db" {
  name     = var.db_name
  instance = google_sql_database_instance.mysql_instance.name
}

resource "google_sql_user" "postgres_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}

resource "google_sql_user" "mysql_user" {
  name     = var.db_user
  instance = google_sql_database_instance.mysql_instance.name
  password = var.db_password
}

