variable "private_key_path" {
  type        = string
  description = "Path to a private key"
}

variable "service_account_email" {
  type = string
#  default = "user:iviulich@gmail.com"
  default = "terraform-user@micro-avenue-459114-p8.iam.gserviceaccount.com"
}
