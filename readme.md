# AWS Service Logs -> Glue Tables  

This module takes service logs (e.g. ALB, NLB, VPC Flow) from S3 and provisions the resources to make the logs query-able in Athena.

## Supported Services

Currently, this module currently allows for structured queries on the following AWS service logs. See [AWS Logging Reference](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AWS-logs-and-resource-policy.html) for complete list.

- [x] Application Load Balancer

## Usage

See `/examples/${SERVICE_NAME}` for specific usage examples for each supported service.

```bash
module "svc_logs" {
  source = "../../"

  # Athena and Glue Configuration
  src_athena_db_name    = aws_athena_database.svc_logs.name
  src_athena_table_name = "alb_001"

  # Source / Destination Location (ALB)
  src_lb_logs_bucket = data.aws_s3_bucket.svc_logs.bucket
  src_lb_logs_prefix = ""
  
}
```
