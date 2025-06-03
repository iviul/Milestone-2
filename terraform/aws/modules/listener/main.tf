locals {
  lstnrs = { for l in var.listeners : l.name => l }
}


# Add listener to load balancer
resource "aws_lb_listener" "this" {
  for_each = local.lstnrs

  load_balancer_arn = var.lb_arns_by_name[each.value.load_balancer]
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = each.value.default_action.type
    target_group_arn = var.tg_arns_by_name[each.value.default_action.target_group]
  }
}