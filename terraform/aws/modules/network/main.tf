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

locals {
  public_subnets      = { for k, sn in local.subnets : k => sn if sn.is_public }
  private_subnets     = { for k, sn in local.subnets : k => sn if !sn.is_public }
  first_public_subnet = keys(local.public_subnets)[0]
}

resource "aws_vpc" "terraform" {
  for_each = local.vpcs

  cidr_block = each.value.vpc_cidr
  tags = {
    Name = each.value.name
  }
}

# Subnets Provision
resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.terraform[each.value.vpc_id].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.is_public

  tags = {
    Name = each.value.name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  for_each = local.vpcs

  vpc_id = aws_vpc.terraform[each.key].id
  tags = {
    Name = "${each.value.name}-igw"
  }
}

locals {
  # Determine if a VPC has private subnets
  vpc_has_private_subnets = {
    for vpc_key, vpc in local.vpcs : 
    vpc_key => length([for subnet in vpc.subnets : subnet if !subnet.public]) > 0
  }
  # Determine if a VPC has public subnets
  vpc_has_public_subnets = {
    for vpc_key, vpc in local.vpcs : 
    vpc_key => length([for subnet in vpc.subnets : subnet if subnet.public]) > 0
  }
}

resource "aws_eip" "nat" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_private_subnets[k] }

  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "${each.value.name}-eip"
  }
}

resource "aws_nat_gateway" "nt" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_private_subnets[k] }

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnets[local.first_public_subnet].id
  depends_on    = [aws_internet_gateway.gw]
  tags          = { Name = "${each.value.name}-nat-gateway" }
}

resource "aws_route_table" "public" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_public_subnets[k] }

  vpc_id = aws_vpc.terraform[each.key].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[each.key].id
  }
  tags = { Name = "${each.value.name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public[each.value.vpc_id].id
}

resource "aws_route_table" "private" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_private_subnets[k] }

  vpc_id = aws_vpc.terraform[each.key].id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nt[each.key].id
  }
  tags = { Name = "${each.value.name}-private-rt" }
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private[each.value.vpc_id].id
}