variable "region" {
  default = "eu-central-1"
}

variable "cloud_provider" {
  description = "Cloud provider (aws, gcp)"
  type        = string
  default     = "aws"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key Id"
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key"
  sensitive   = true
}
