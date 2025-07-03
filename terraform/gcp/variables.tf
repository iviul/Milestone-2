variable "gcp_credentials_file" {
  description = "Path to the GCP credentials JSON file"
  type        = string
  default     = "keys.json"
}

variable "health_check_port" {
  description = "Port used for health checks (default: 6443 for K3s)"
  type        = number
  default     = 6443
}

variable "cloudflare_zone_id" {
  type        = string
  sensitive   = true
  description = "Cloudflare zone ID for DNS management"
  default     = "f2ecb3eb8c0cf84bb53c314e402ff57d"
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
  sensitive   = true
  default     = "5af6bf3ecbff8088b428a44a2a79e82777859"
}

variable "JENKINS_GITHUB_SSH_PRIVATE_KEY" {
  type = string
}

variable "cloud_bucket" {
  type        = string
  description = "Name of the Google Cloud Storage bucket for Terraform state"
}

variable "gar_password_base64" {
  description = "Base64-encoded password for GAR (Google Artifact Registry) authentication."
  type        = string
  sensitive   = true
}
