output "listeners" {
  value = local.lstnrs
}

# output "listeners_arns_by_name" {
#   value = { for k, l in aws_lb_listener.this : k => l.arn }
# }