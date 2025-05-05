variable "region" {
  default = "eu-north-1"
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