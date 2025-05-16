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
}

variable "private_key_path" {
  type = string
  description = "Path to a private key"
}

