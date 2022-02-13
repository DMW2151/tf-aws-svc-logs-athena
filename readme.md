
**Note:** Thought I would use this for a presentation in 1/2022. Ended up not needing it. Assume it's WIP and not safe for use while this message is here.

&mdash; DW

# Querying AWS Service Logs

This module takes service logs (e.g. ALB, WAF, VPC Flow) stored in S3 and provisions the corresponding Athena resources to make the logs query-able in Athena. This module will likely be most useful to you as a starting point for your own, more tailored implementation. The `src_${service}_athena.tf` files in this directory each translate the most recent log schema for an AWS service to an AWS Glue catalog table.

Please note, this module does not deploy any load balancers, VPCs, etc, just the Athena and Glue resources to query logs emitted from those services. If you'd like to deploy a test application (including an ALB, VPC, and WAF rules), please refer to [Service Log Sample](./examples/readme.md).

Currently, this module currently allows for structured queries on the following AWS service logs. See [AWS Logging Reference](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AWS-logs-and-resource-policy.html) for a complete list of AWS services that sink logs into S3.

| Service                   | Schema Reference                                                                                                                       | Common Query Reference |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------|----------------------- |
| Application Load Balancer | [ALB Logs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-log-entry-format) | [ALB Queries](https://docs.aws.amazon.com/athena/latest/ug/application-load-balancer-logs.html)                |
| VPC Flow                  | [VPC Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html#flow-logs-fields)                                           | [VPC Flow Queries](https://docs.aws.amazon.com/athena/latest/ug/vpc-flow-logs.html)                |
| Web Application Firewall  | [WAF Logs](https://docs.aws.amazon.com/waf/latest/developerguide/logging-fields.html)                                                  | [WAF Queries](https://docs.aws.amazon.com/athena/latest/ug/waf-logs.html)               |

## Usage

Examples covering several cases are available in `/examples/**`. In general, they follow a pattern as shown below.

```bash

# Create (or provide) an Athena DB for service logs
resource "aws_athena_database" "logs" {
  name   = "logs"
  bucket = "service_logs_db_query_results"
}

module "svc_logs" {

  source = "../../"

  # Athena and Glue Configuration
  athena_db_name = aws_athena_database.logs.name

  # Source / Destination Location (ALB)
  svc_logs_bucket = "service_logs_source_bucket"

  # Optional S3 prefix for each supported service
  alb_logs_prefix     = ""
  waf_logs_prefix     = ""
  vpcflow_logs_prefix = ""

  # Options for Projected Partitioning
  enable_projected_partitions = true

  organization_account_ids = [
    data.aws_caller_identity.current.id
  ]

  organization_enabled_regions = [
    "us-east-1",
    "us-west-2",
    "eu-central-1"
  ]

}
```

## Note on Projected Partitioning

This module uses a relatively new feature of Athena called [projected partitioning](https://docs.aws.amazon.com/athena/latest/ug/partition-projection.html). You can read more about projected partitioning [here](https://aws.amazon.com/about-aws/whats-new/2020/06/amazon-athena-supports-partition-projection/).

> Partition projection allows you to specify configuration information such as the patterns (for example, YYYY/MM/DD) that are commonly used to form partitions. This gives Athena the information necessary to build partitions without retrieving metadata information from your metadata store. Athena will read the partition values and locations from configuration, rather than from a repository like the AWS Glue Data Catalog. Partition projection reduces the runtime of queries against highly partitioned tables since in-memory operations are often faster than remote operations.

The most significant advantage projected partitioning offers is that is that developers no longer need to configure a Glue crawler, Glue ETL job, or scheduled Athena query to add new partitions to their tables. This is particularly useful for AWS service logs, which are often partitioned hourly. However, Enabling partition projection on a table causes Athena to ignore any partition metadata registered to the table in the AWS Glue Data Catalog or Hive metastore. You can enable or disable projected partitioning on a table with the `${SERVICE}_enable_projected_partitions` option.
