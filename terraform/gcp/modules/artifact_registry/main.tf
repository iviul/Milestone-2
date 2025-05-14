resource "google_artifact_registry_repository" "artifact_repo" {
  location      = var.region
  repository_id = var.artifact_registry_id
  description   = var.artifact_registry_description
  format        = var.artifact_registry_format

  docker_config {
    immutable_tags = true
  }
}
