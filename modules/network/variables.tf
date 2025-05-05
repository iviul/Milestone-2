variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_tags" {
  description = "Tags for the VPC"
  type        = map(string)
  default     = { Name = "terraform" }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/26"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.0.64/26"
}

variable "db_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.0.128/26"
}

variable "public_az" {
  description = "Availability Zone ID for public subnet"
  type        = string
  default     = "euc1-az2"
}

variable "private_az" {
  description = "Availability Zone ID for private subnet"
  type        = string
  default     = "euc1-az2"
}

variable "db_az" {
  description = "Availability Zone ID for db subnet"
  type        = string
  default     = "euc1-az1"
}

variable "public_subnet_tags" {
  description = "Tags for public subnet"
  type        = map(string)
  default     = { Name = "public" }
}

variable "private_subnet_tags" {
  description = "Tags for private subnet"
  type        = map(string)
  default     = { Name = "private" }
}

variable "db_subnet_tags" {
  description = "Tags for db subnet"
  type        = map(string)
  default     = { Name = "db" }
}

variable "internet_route_cidr" {
  description = "CIDR block for internet route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "route_table_tags" {
  description = "Tags for the route table"
  type        = map(string)
  default     = { Name = "terraform" }
}

variable "security_group_tags" {
  description = "Tags for the security group"
  type        = map(string)
  default     = { Name = "instances" }
}

variable "http_ingress1" {
  description = "Ingress rule 1 for HTTP"
  type = object({
    description = string
    cidr_ipv4   = string
    from_port   = number
    ip_protocol = string
    to_port     = number
  })
  default = {
    description = "Allow HTTP inbound traffic"
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 8080
    ip_protocol = "tcp"
    to_port     = 8080
  }
}

variable "http_ingress2" {
  description = "Ingress rule 2 for HTTP"
  type = object({
    description = string
    cidr_ipv4   = string
    from_port   = number
    ip_protocol = string
    to_port     = number
  })
  default = {
    description = "Allow HTTP inbound traffic on port 5000"
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 5000
    ip_protocol = "tcp"
    to_port     = 5000
  }
}

variable "ssh_ingress" {
  description = "Ingress rule for SSH"
  type = object({
    description = string
    cidr_ipv4   = string
    from_port   = number
    ip_protocol = string
    to_port     = number
  })
  default = {
    description = "Allow SSH inbound traffic"
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
}

variable "rds_ingress" {
  description = "Ingress rule for RDS"
  type = object({
    description = string
    cidr_ipv4   = string
    from_port   = number
    ip_protocol = string
    to_port     = number
  })
  default = {
    description = "Allow inbound traffic from my IP and EC2 security group"
    cidr_ipv4   = "46.133.65.59/32" # My IP
    from_port   = 5432
    ip_protocol = "tcp"
    to_port     = 5432
  }
}

variable "igw_tags" {
  description = "Tags for the Internet Gateway"
  type        = map(string)
  default     = { Name = "main" }
}

variable "assign_public_ip" {
  description = "Assign public IP?"
  type = bool
  default = false
}