resource "aws_lambda_function" "discord_alert" {
  filename         = "${path.module}/lambda/function.zip"
  function_name    = "discord_alert_lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")
  runtime          = "python3.12"
  environment {
    variables = {
      DISCORD_WEBHOOK_URL = var.discord_webhook_url
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "discord_alert_lambda_exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_sns_topic" "discord_alerts" {
  name = "discord-alerts"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.discord_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.discord_alert.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.discord_alert.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.discord_alerts.arn
}

# CloudWatch Alarms for EC2
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  for_each            = toset(var.ec2_instance_ids)
  alarm_name          = "EC2-${each.key}-High-CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 instance ${each.key} high CPU utilization."
  dimensions = {
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk_read" {
  for_each            = toset(var.ec2_instance_ids)
  alarm_name          = "EC2-${each.key}-DiskReadOps"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskReadOps"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Sum"
  threshold           = 10000
  alarm_description   = "EC2 instance ${each.key} high disk read ops."
  dimensions = {
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk_write" {
  for_each            = toset(var.ec2_instance_ids)
  alarm_name          = "EC2-${each.key}-DiskWriteOps"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskWriteOps"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Sum"
  threshold           = 10000
  alarm_description   = "EC2 instance ${each.key} high disk write ops."
  dimensions = {
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_network_in" {
  for_each            = toset(var.ec2_instance_ids)
  alarm_name          = "EC2-${each.key}-NetworkIn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000000000
  alarm_description   = "EC2 instance ${each.key} high network in."
  dimensions = {
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_network_out" {
  for_each            = toset(var.ec2_instance_ids)
  alarm_name          = "EC2-${each.key}-NetworkOut"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000000000
  alarm_description   = "EC2 instance ${each.key} high network out."
  dimensions = {
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  for_each            = toset(var.ec2_instance_ids)
  alarm_name          = "EC2-${each.key}-StatusCheckFailed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "EC2 instance ${each.key} status check failed."
  dimensions = {
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

# CloudWatch Alarms for RDS
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  for_each            = toset(var.rds_instance_ids)
  alarm_name          = "RDS-${each.key}-High-CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS instance ${each.key} high CPU utilization."
  dimensions = {
    DBInstanceIdentifier = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  for_each            = toset(var.rds_instance_ids)
  alarm_name          = "RDS-${each.key}-Low-Storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_storage_threshold
  alarm_description   = "RDS instance ${each.key} low free storage space."
  dimensions = {
    DBInstanceIdentifier = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  for_each            = toset(var.rds_instance_ids)
  alarm_name          = "RDS-${each.key}-DatabaseConnections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "RDS instance ${each.key} high database connections."
  dimensions = {
    DBInstanceIdentifier = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_read_latency" {
  for_each            = toset(var.rds_instance_ids)
  alarm_name          = "RDS-${each.key}-ReadLatency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 0.1
  alarm_description   = "RDS instance ${each.key} high read latency."
  dimensions = {
    DBInstanceIdentifier = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_write_latency" {
  for_each            = toset(var.rds_instance_ids)
  alarm_name          = "RDS-${each.key}-WriteLatency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 0.1
  alarm_description   = "RDS instance ${each.key} high write latency."
  dimensions = {
    DBInstanceIdentifier = each.key
  }
  alarm_actions = [aws_sns_topic.discord_alerts.arn]
}
