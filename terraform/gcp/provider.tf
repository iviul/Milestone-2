provider "google" {
  project     = local.config.project.name
  region      = local.region
  credentials = file("keys.json")
}

terraform {
  backend "gcs" {
    prefix = "terraform/state"
  }
}
