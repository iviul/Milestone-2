variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "postgres-vpc"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "postgres-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "region" {
  description = "Region for the VPC and subnet"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access PostgreSQL"
  type        = list(string)
  default     = ["0.0.0.0/0"] 
}

variable "ssh_allowed_ip_ranges" {
  description = "List of IP ranges allowed to access via SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"] 
}
