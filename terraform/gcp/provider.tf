provider "google" {
  project     = local.config.project.name
  region      = local.region
  credentials = file("${path.module}/keys.json")
}

terraform {
  backend "gcs" {
    prefix = "terraform/state"
  }
}
