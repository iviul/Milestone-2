locals {
  lbs = { for lb in var.load_balancers : lb.name => lb }
}


# Create an application load balancer
resource "aws_lb" "this" {
  for_each = local.lbs

  name               = each.value.name
  internal           = each.value.internal
  load_balancer_type = each.value.load_balancer_type

  subnets = [
    for subnet_key in each.value.subnets : var.subnets["main-${subnet_key}"].id
  ]

  security_groups = [
    for sg_key in each.value.security_groups : var.security_groups[sg_key]
  ]

  tags = {
    Name = each.value.name
  }
}