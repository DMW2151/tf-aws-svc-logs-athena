terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }

  required_version = ">= 1.0.3"

}

// Providers
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Test"
      Project     = "Test Service Logs - Athena (ALB)"
    }
  }
}


// Get Caller ID - Account ID
data "aws_caller_identity" "current" {}

// Create a Temporary Athena DB
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_database
resource "aws_athena_database" "svc_logs" {
  name   = "svc_logs"
  bucket = "tf-athena-svc-logs-proper-bear"
}

module "svc_logs" {

  source = "../../"

  # Athena and Glue Configuration
  athena_db_name = aws_athena_database.logs.name

  # Source / Destination Location (ALB)
  src_logs_bucket = "service_logs_source_bucket"

  # Optional S3 prefix for each supported service
  alb_logs_prefix     = ""
  waf_logs_prefix     = ""
  vpcflow_logs_prefix = ""

  # Additional Options for Projected Partitioning
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
