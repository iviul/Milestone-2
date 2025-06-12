variable "region" {
  default = "eu-central-1"
}

variable "cloud_provider" {
  description = "Cloud provider (aws, gcp)"
  type        = string
  default     = "aws"
}

variable "aws_user" {
  description = "AWS CLI profile name to use"
  type        = string
  default     = "terraform-user"
}

variable "private_key_path" {
  type        = string
  description = "Path to a private key"
  default     = "/home/user/.ssh"
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type    = string
  default = "42b42abbecbb7793d4e4f1d20b1f836f"
}


