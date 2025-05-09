provider "google" {
  project = var.project_id
  region  = local.region
  credentials = file("keys.json")
}

# Terraform docs re: configuring back end: https://www.terraform.io/docs/backends/types/gcs.html
terraform {
  backend "gcs" {
    prefix  = "terraform/state"
//    bucket  = "" #these will be passed as backend-config variables in the terraform init. See cloubuild.yaml.
//    project = ""
  }
}
