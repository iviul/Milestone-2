locals {
  tgs = { for tg in var.target_groups : tg.name => tg }

  vms = {
    for tg_name, tg in local.tgs :
    tg_name => {
      port = tg.port
      instances = [
        for vm_name in tg.vm :
        var.vm_ids_by_name[vm_name]
      ]
    }
  }

  vms_test = merge(
    flatten([
      for group_name, group_data in local.vms : [
        for idx, instance_id in group_data.instances : {
          "${group_name}-${idx}" = {
            instance_id = instance_id
            group       = group_name
            port        = group_data.port
          }
        }
      ]
    ])...
  )
}

# Create a load balancer target group
resource "aws_lb_target_group" "target_group" {
  for_each = local.tgs

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = each.value.target_type
  vpc_id      = var.vpc_ids_by_name[each.value.vpc]
}

# Attach instaces to target group
resource "aws_lb_target_group_attachment" "target_group_attachment" {
  for_each = local.vms_test

  target_group_arn = aws_lb_target_group.target_group[each.value.group].arn
  target_id        = each.value.instance_id
  port             = each.value.port
}
