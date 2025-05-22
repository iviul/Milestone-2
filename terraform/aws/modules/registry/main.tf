locals {
  registry = {
    for r in var.config.artifact_registry : "${r.provider}-${r.name}" => r
    if r.provider == "aws"
  }
  docker_registries = {
    for k, r in local.registry : k => r
    if r.repository_type == "docker" && r.enabled == true
  }
}

resource "aws_ecr_repository" "registry" {
  for_each = local.docker_registries

  name = each.value.name
}