variable "region" {
  description = "The region where the Artifact Registry will be created."
}

variable "artifact_registry_id" {
  description = "A unique identifier for the Artifact Registry."
}

variable "artifact_registry_description" {
  description = "A description for the Artifact Registry."
}

variable "artifact_registry_format" {
  description = "The format of the Artifact Registry, e.g., DOCKER."
  default     = "DOCKER"
} 