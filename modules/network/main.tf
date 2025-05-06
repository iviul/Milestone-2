locals {
  vpcs = { for vpc in var.vpcs : vpc.name => vpc }

  subnets = merge([
    for vpc_key, vpc in local.vpcs : {
      for subnet in vpc.subnets :
      "${vpc_key}-${subnet.name}" => {
        vpc_id            = vpc_key
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        is_public         = subnet.is_public
        tags              = subnet.tags
      }
    }
  ]...)

  sgs = merge([
    for vpc_key, vpc in local.vpcs : {
      for sg in vpc.security-groups :
      "${vpc_key}-${sg.name}" => {
        vpc_id = vpc_key
        name = sg.name
        description = sg.description
        ingress = sg.ingress
        egress = sg.egress
      }
    }
  ]...)

  ingrs = merge([
    for sg_key, sg in local.sgs : {
      for ingr in sg.ingress :
      "${sg_key}-ingress" => {
        sg_id = sg_key
        protocol = ingr.protocol
        port = ingr.port
        source = ingr.source
      }
    }
  ]...)
}

resource "aws_vpc" "terraform" {
  for_each = local.vpcs

  cidr_block = each.value.vpc_cidr
  # enable_dns_hostnames = true

  tags = each.value.tags
}

# Subnets Provision
resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.terraform[each.value.vpc_id].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.is_public

  tags = each.value.tags
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  for_each = local.vpcs

  vpc_id = aws_vpc.terraform[each.key].id
}

# Route Table
resource "aws_route_table" "rt" {
  for_each = local.vpcs

  vpc_id = aws_vpc.terraform[each.key].id

  route {
    cidr_block = each.value.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = var.internet_route_cidr
    gateway_id = aws_internet_gateway.gw[each.key].id
  }
}

resource "aws_main_route_table_association" "a" {
  for_each = local.vpcs

  vpc_id         = aws_vpc.terraform[each.key].id
  route_table_id = aws_route_table.rt[each.key].id
}

# Security Group for RDS
resource "aws_security_group" "sg" {
  for_each = local.sgs

  name        = each.value.name # Name can not start with "sg-"
  description = each.value.description
  vpc_id      = aws_vpc.terraform[each.value.vpc_id].id
}

# Security Group Rules for RDS
resource "aws_vpc_security_group_ingress_rule" "sgr" {
  for_each = local.ingrs

  security_group_id = aws_security_group.sg[each.value.sg_id].id
  from_port        = each.value.port
  ip_protocol      = each.value.protocol
  to_port          = each.value.port
  referenced_security_group_id = aws_security_group.sg["main-sg_${each.value.source}"].id
}

# # Security Group
# resource "aws_security_group" "instances" {
#   name        = "instances"
#   description = "Allow HTTP, SSH inbound traffic and all outbound traffic"
#   vpc_id      = aws_vpc.terraform.id

#   tags = var.security_group_tags
# }


# # Security Group Rules for EC2
# resource "aws_vpc_security_group_ingress_rule" "tcp" {
#   security_group_id = aws_security_group.instances.id
#   description       = var.http_ingress1.description
#   cidr_ipv4        = var.http_ingress1.cidr_ipv4
#   from_port        = var.http_ingress1.from_port
#   ip_protocol      = var.http_ingress1.ip_protocol
#   to_port          = var.http_ingress1.to_port
# }

# resource "aws_vpc_security_group_ingress_rule" "tcp2" {
#   security_group_id = aws_security_group.instances.id
#   description       = var.http_ingress2.description
#   cidr_ipv4        = var.http_ingress2.cidr_ipv4
#   from_port        = var.http_ingress2.from_port
#   ip_protocol      = var.http_ingress2.ip_protocol
#   to_port          = var.http_ingress2.to_port
# }

# resource "aws_vpc_security_group_ingress_rule" "ssh" {
#   security_group_id = aws_security_group.instances.id
#   description       = var.ssh_ingress.description
#   cidr_ipv4        = var.ssh_ingress.cidr_ipv4
#   from_port        = var.ssh_ingress.from_port
#   ip_protocol      = var.ssh_ingress.ip_protocol
#   to_port          = var.ssh_ingress.to_port
# }

# resource "aws_vpc_security_group_egress_rule" "all" {
#   security_group_id = aws_security_group.instances.id
#   description       = "Allow all outbound traffic"
#   cidr_ipv4        = "0.0.0.0/0"
#   ip_protocol      = "-1" # specify all protocols
# }