variable "cluster_endpoint" {
  type = string
}

variable "ca_certificate" {
  type = string
}

variable "access_token" {
  type = string
}

variable "jenkins_namespace" {
  type    = string
  default = "jenkins"
}

variable "jenkins_hostname" {
  type        = string
  description = "Hostname for the Jenkins instance"
}

variable "jenkins_admin_username" {
  type        = string
  description = "Username for the Jenkins admin user"
}

variable "jenkins_admin_password" {
  type        = string
  description = "Password for the Jenkins admin user"
}

variable "gcp_credentials_file" {
  description = "Path to the GCP credentials file"
  type        = string
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
  sensitive   = true
}

variable "JENKINS_GITHUB_SSH_PRIVATE_KEY" {
  description = "Private SSH key for GitHub"
  type        = string
  sensitive   = true
}

variable "jenkins_controller_registry" {
  type        = string
  description = "Docker registry for Jenkins controller image"
}

variable "jenkins_controller_repository" {
  type        = string
  description = "Name of the TLS secret for Jenkins"
  default     = "nginx-hello-tls-secret"
}

variable "jenkins_controller_tag" {
  type        = string
  description = "Tag for the Jenkins controller image"
}

variable "cloud_bucket" {
  type        = string
  description = "Name of the Google Cloud Storage bucket for Terraform state"
}

variable "gar_password_base64" {
  description = "Base64-encoded password for GAR (Google Artifact Registry) authentication."
  type        = string
  sensitive = true
  }

variable "project_id" {
  type        = string
  description = "GCP project ID"
}
