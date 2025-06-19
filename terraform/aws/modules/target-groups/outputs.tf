output "tgs" {
  value = local.tgs
}

output "tg_arns_by_name" {
  value = { for k, tg in aws_lb_target_group.target_group : k => tg.arn }
}