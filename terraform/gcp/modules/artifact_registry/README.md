# Artifact Registry Module

This module creates an Artifact Registry repository on Google Cloud Platform (GCP) for storing Docker images.

## Inputs
- `project_id`: The ID of the GCP project.
- `region`: The region where the Artifact Registry will be created.
- `artifact_registry_id`: A unique identifier for the Artifact Registry.
- `artifact_registry_description`: A description for the Artifact Registry.
- `artifact_registry_format`: The format of the Artifact Registry, e.g., DOCKER.

## Outputs
- `repository_url`: The URL of the created Artifact Registry repository. 