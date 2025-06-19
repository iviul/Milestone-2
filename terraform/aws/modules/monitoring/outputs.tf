output "cloudwatch_alarm_arns" {
  description = "ARNs of created CloudWatch alarms."
  value       = aws_cloudwatch_metric_alarm.all[*].arn
}
