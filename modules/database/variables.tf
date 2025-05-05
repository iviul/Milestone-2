variable "db_config" {}

variable "subnet_ids" {
  description = "Subnet IDs for subnet group"
  type = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type = list(string)
}