variable "private_key_path" {
  type        = string
  description = "Path to a private key"
}

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
  default     = "42b42abbecbb7793d4e4f1d20b1f836f"
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
  sensitive   = true
  default = "aJLTlqyMHshCQ6EovdpjIQjDphJ2I308vI9Y2htU"
}

variable "JENKINS_GITHUB_SSH_PRIVATE_KEY" {
  type = string
}
