terraform {

  backend "s3" {
    bucket = "dmw2151-state"
    key    = "state_files/service-logs.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }

  required_version = ">= 1.0.3"

}

# Providers
provider "aws" {
  region  = "us-east-1"
  profile = "dmw2151"
}

# Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
data "aws_s3_bucket" "svc_logs" {
  bucket = "dmw2151-service-logs"
}

# Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_database
resource "aws_athena_database" "svc_logs" {
  name   = "svc_logs"
  bucket = aws_s3_bucket.svc_logs.bucket
}


module "svc_logs" {
  source = "../../"

  # Source / Destination Location (S3)
  src_lb_logs_bucket = aws_s3_bucket.svc_logs.bucket
  
  # Athena and Glue Configuration
  src_athena_db_name    = aws_athena_database.svc_logs.name
  src_athena_table_name = "alb_001"

}