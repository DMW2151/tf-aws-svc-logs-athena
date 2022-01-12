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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.70 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.70 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_glue_catalog_table.alb_logs_src](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization_account_ids"></a> [organization\_account\_ids](#input\_organization\_account\_ids) | Associated account IDs -> Used for Projected Partitioning | `list(string)` | n/a | yes |
| <a name="input_src_athena_catalog_id"></a> [src\_athena\_catalog\_id](#input\_src\_athena\_catalog\_id) | Path of the Source ALB logs... | `string` | `"default"` | no |
| <a name="input_src_athena_db_name"></a> [src\_athena\_db\_name](#input\_src\_athena\_db\_name) | Athena DB to place Table into... | `string` | n/a | yes |
| <a name="input_src_athena_table_name"></a> [src\_athena\_table\_name](#input\_src\_athena\_table\_name) | Path of the Source ALB logs... | `string` | n/a | yes |
| <a name="input_src_lb_logs_bucket"></a> [src\_lb\_logs\_bucket](#input\_src\_lb\_logs\_bucket) | The name of the S3 bucket. | `string` | n/a | yes |
| <a name="input_src_lb_logs_prefix"></a> [src\_lb\_logs\_prefix](#input\_src\_lb\_logs\_prefix) | The prefix (logical hierarchy) in the bucket. If you don't specify a prefix, assumes the logs are placed at the root level of the bucket. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_table"></a> [alb\_table](#output\_alb\_table) | The Catalog table... |
<!-- END_TF_DOCS -->