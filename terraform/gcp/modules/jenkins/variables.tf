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

variable "admin_user" {
  type    = string
  default = "admin"
}

variable "admin_password" {
  type    = string
  default = "admin"
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
  description = "Path to the GCP credentials JSON file"
  type        = string
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
  sensitive   = true
}

variable "jenkins_github_ssh_private_key" {
  type        = string
  description = "SSH private key for GitHub access in Jenkins"
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
  description = "Docker repository for Jenkins controller image"
}

variable "jenkins_controller_tag" {
  type        = string
  description = "Tag for the Jenkins controller image"
}