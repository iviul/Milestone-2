variable "private_key_path" {
  type        = string
  description = "Path to a private key"
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
}