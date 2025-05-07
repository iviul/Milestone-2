provider "google" {
  project = local.config.project.project_id
  region  = local.config.project.region
}
