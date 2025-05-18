provider "google" {
  project     = var.project_id
  region      = local.region
  credentials = file("keys.json")
}

terraform {
  backend "gcs" {
    prefix = "terraform/state"
  }
}
