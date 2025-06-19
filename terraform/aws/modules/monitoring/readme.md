# Monitoring Module

This Terraform module creates CloudWatch alarms for EC2 and RDS resources and sends alert notifications to a Discord channel via a Lambda function and SNS.

## Features

- **EC2 Monitoring:**  
  - CPUUtilization
  - DiskReadOps / DiskWriteOps
  - NetworkIn / NetworkOut
  - StatusCheckFailed

- **RDS Monitoring:**  
  - CPUUtilization
  - FreeStorageSpace
  - DatabaseConnections
  - ReadLatency / WriteLatency

- **Alerting:**  
  - High CPU (e.g., EC2 > 80% for 5 minutes)
  - Low disk space (e.g., < 10% free)
  - Instance status check failed
  - RDS free storage below threshold

- **Notifications:**  
  - Alerts are sent to a Discord webhook using a Lambda function triggered by SNS.

## Usage Example

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  discord_webhook_url   = var.discord_webhook_url
  ec2_instance_ids      = values(module.vms.vm_ids_by_name)
  rds_instance_ids      = values(module.db.db_hosts)
  # rds_instance_ids should be the DBInstanceIdentifier, adjust if needed
  rds_storage_threshold = 10737418240 # 10GB, adjust as needed
  depends_on            = [module.vms]
}
```

## Inputs

| Name                  | Description                                         | Type     | Required |
|-----------------------|-----------------------------------------------------|----------|----------|
| discord_webhook_url   | Discord webhook URL for notifications               | string   | yes      |
| ec2_instance_ids      | List of EC2 instance IDs to monitor                 | list     | yes      |
| rds_instance_ids      | List of RDS instance identifiers to monitor         | list     | yes      |
| rds_storage_threshold | Free storage threshold for RDS alarms (in bytes)    | number   | yes      |

## Outputs

None.

## Notes

- Ensure your Lambda function zip is built and present at `lambda/function.zip`.
- The module creates an SNS topic and subscribes the Lambda to it. CloudWatch alarms send notifications to SNS, which triggers the Lambda.
- The Lambda function expects the environment variable `DISCORD_WEBHOOK_URL` to be set.

## License

MIT