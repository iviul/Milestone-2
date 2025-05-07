locals {
  vpcs = { for vpc in var.vpcs : vpc.name => vpc }

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  subnets = merge([
    for vpc_key, vpc in local.vpcs : {
      for subnet in vpc.subnets :
      "${vpc_key}-${subnet.name}" => {
        vpc_id            = vpc_key
        cidr_block        = subnet.cidr
        availability_zone = "${local.fixed_region_map.aws}${subnet.zone}"
        is_public         = subnet.public
      }
    }
  ]...)
}

resource "aws_vpc" "terraform" {
  for_each = local.vpcs

  cidr_block = each.value.vpc_cidr
}

# Subnets Provision
resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.terraform[each.value.vpc_id].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.is_public
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
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[each.key].id
  }
}

resource "aws_main_route_table_association" "a" {
  for_each = local.vpcs

  vpc_id         = aws_vpc.terraform[each.key].id
  route_table_id = aws_route_table.rt[each.key].id
}