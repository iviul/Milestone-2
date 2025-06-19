output "load_balancers" {
  value = local.lbs
}

output "lb_arns_by_name" {
  value = { for k, lb in aws_lb.this : k => lb.arn }
}

output "lb_dns_names" {
  value = { for k, lb in aws_lb.this : k => lb.dns_name }
}