locals {
  vpcs = { for vpc in var.vpcs : vpc.name => vpc }

  subnets = merge([
    for vpc_key, vpc in local.vpcs : {
      for subnet in vpc.subnets :
      "${vpc_key}-${subnet.name}" => {
        name              = subnet.name
        vpc_id            = vpc_key
        cidr_block        = subnet.cidr
        availability_zone = "${var.region.aws}${subnet.zone}"
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

resource "aws_eip" "nat" {
  for_each = local.vpcs

  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

locals {
  public_subnets      = { for k, sn in local.subnets : k => sn if sn.is_public }
  private_subnets     = { for k, sn in local.subnets : k => sn if !sn.is_public }
  first_public_subnet = keys(local.public_subnets)[0]
}

resource "aws_nat_gateway" "nt" {
  for_each = local.vpcs

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnets[local.first_public_subnet].id
  depends_on    = [aws_internet_gateway.gw]
  tags          = { Name = "nat-gateway" }
}

resource "aws_route_table" "public" {
  for_each = local.vpcs

  vpc_id = aws_vpc.terraform[each.key].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[each.key].id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public[each.value.vpc_id].id
}

resource "aws_route_table" "private" {
  for_each = local.vpcs

  vpc_id = aws_vpc.terraform[each.key].id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nt[each.key].id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private[each.value.vpc_id].id
}