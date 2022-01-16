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
resource "aws_athena_database" "logs" {
  name   = "aws_svc_logs"
  bucket = var.athena_query_results_bucket_name
}

module "svc_logs" {

  source = "../../"

  // Athena and Glue Configuration
  athena_db_name = aws_athena_database.logs.name

  // Source / Destination Location (ALB)
  svc_logs_bucket = var.svc_logs_bucket_name

  // Optional S3 prefix for each supported service
  alb_logs_prefix = ""

  // Additional Options for Projected Partitioning / Partition Indexing
  enable_projected_partitions = true
  enable_partition_filtering  = false

  organization_account_ids = [
    data.aws_caller_identity.current.id
  ]

  organization_enabled_regions = [
    "us-east-1",
    "us-west-2"
  ]

}
