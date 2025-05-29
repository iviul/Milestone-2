resource "aws_security_group" "all" {
  for_each = { for sg in var.security_groups : sg.name => sg }

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_ids_by_name[each.value.vpc]
}

resource "aws_vpc_security_group_ingress_rule" "all" {
  for_each = {
    for item in flatten([
      for sg in var.security_groups : [
        for rule in sg.ingress :
        {
          sg_name  = sg.name
          protocol = rule.protocol
          port     = rule.port
          source   = rule.source
        }
      ]
    ]) : "${item.sg_name}-${item.protocol}-${item.port}-${item.source}" => item
  }

  security_group_id = aws_security_group.all[each.value.sg_name].id
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = each.value.protocol

  cidr_ipv4 = contains(keys(var.networks_by_name), each.value.source) ? var.networks_by_name[each.value.source] : null

  referenced_security_group_id = contains(keys(aws_security_group.all), each.value.source) ? aws_security_group.all[each.value.source].id : null
}

resource "aws_vpc_security_group_egress_rule" "all" {
  for_each = {
    for item in flatten([
      for sg in var.security_groups : [
        for rule in sg.egress :
        {
          sg_name     = sg.name
          protocol    = rule.protocol
          port        = rule.port
          destination = rule.destination
        }
      ]
    ]) : "${item.sg_name}-${item.protocol}-${item.port == null ? "" : item.port}-${item.destination}" => item
  }

  security_group_id = aws_security_group.all[each.value.sg_name].id
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = each.value.protocol

  cidr_ipv4 = contains(keys(var.networks_by_name), each.value.destination) ? var.networks_by_name[each.value.destination] : null

  referenced_security_group_id = contains(keys(aws_security_group.all), each.value.destination) ? aws_security_group.all[each.value.destination].id : null
}
