variable "config" {}

variable "subnets" {
  description = "Subnet IDs for subnet group"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
}