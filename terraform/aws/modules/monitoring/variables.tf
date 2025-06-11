# Variables for monitoring module
variable "discord_webhook_url" {
  description = "Discord webhook URL for alerts."
  type        = string
}

variable "ec2_instance_ids" {
  description = "List of EC2 instance IDs to monitor."
  type        = list(string)
}

variable "rds_instance_ids" {
  description = "List of RDS instance identifiers to monitor."
  type        = list(string)
}

variable "rds_storage_threshold" {
  description = "Free storage space threshold for RDS (in bytes)."
  type        = number
  default     = 10737418240 # 10GB
}
