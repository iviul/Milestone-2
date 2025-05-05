resource "aws_vpc" "terraform" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = var.vpc_tags
}

# Subnets Provision
resource "aws_subnet" "public" {
  vpc_id               = aws_vpc.terraform.id
  cidr_block           = var.public_subnet_cidr
  availability_zone_id = var.public_az
  map_public_ip_on_launch = var.assign_public_ip

  tags = var.public_subnet_tags
}

resource "aws_subnet" "private" {
  vpc_id               = aws_vpc.terraform.id
  cidr_block           = var.private_subnet_cidr
  availability_zone_id = var.private_az

  tags = var.private_subnet_tags
}

resource "aws_subnet" "db" {
  vpc_id               = aws_vpc.terraform.id
  cidr_block           = var.db_subnet_cidr
  availability_zone_id = var.db_az

  tags = var.db_subnet_tags
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform.id

  tags = var.igw_tags
}

# Route Table
resource "aws_route_table" "test" {
  vpc_id = aws_vpc.terraform.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = var.internet_route_cidr
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = var.route_table_tags
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.terraform.id
  route_table_id = aws_route_table.test.id
}

# Security Group
resource "aws_security_group" "instances" {
  name        = "instances"
  description = "Allow HTTP, SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.terraform.id

  tags = var.security_group_tags
}

# Security Group Rules for EC2
resource "aws_vpc_security_group_ingress_rule" "tcp" {
  security_group_id = aws_security_group.instances.id
  description       = var.http_ingress1.description
  cidr_ipv4        = var.http_ingress1.cidr_ipv4
  from_port        = var.http_ingress1.from_port
  ip_protocol      = var.http_ingress1.ip_protocol
  to_port          = var.http_ingress1.to_port
}

resource "aws_vpc_security_group_ingress_rule" "tcp2" {
  security_group_id = aws_security_group.instances.id
  description       = var.http_ingress2.description
  cidr_ipv4        = var.http_ingress2.cidr_ipv4
  from_port        = var.http_ingress2.from_port
  ip_protocol      = var.http_ingress2.ip_protocol
  to_port          = var.http_ingress2.to_port
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.instances.id
  description       = var.ssh_ingress.description
  cidr_ipv4        = var.ssh_ingress.cidr_ipv4
  from_port        = var.ssh_ingress.from_port
  ip_protocol      = var.ssh_ingress.ip_protocol
  to_port          = var.ssh_ingress.to_port
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.instances.id
  description       = "Allow all outbound traffic"
  cidr_ipv4        = "0.0.0.0/0"
  ip_protocol      = "-1" # specify all protocols
}

# Security Group Rules for RDS
resource "aws_security_group" "rds_sg" {
  name        = "RDS security group"
  description = "Allow inbound traffic from my IP and EC2 (whithin sg)"
  vpc_id      = aws_vpc.terraform.id

  tags = { Name = "RDS security group" }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ec2" {
  security_group_id = aws_security_group.rds_sg.id
  description       = var.rds_ingress.description
  from_port        = var.rds_ingress.from_port
  ip_protocol      = var.rds_ingress.ip_protocol
  to_port          = var.rds_ingress.to_port
  referenced_security_group_id = aws_security_group.instances.id
}

resource "aws_vpc_security_group_ingress_rule" "my_ip" {
  security_group_id = aws_security_group.rds_sg.id
  description       = var.rds_ingress.description
  from_port        = var.rds_ingress.from_port
  ip_protocol      = var.rds_ingress.ip_protocol
  to_port          = var.rds_ingress.to_port
  cidr_ipv4 = var.rds_ingress.cidr_ipv4
}