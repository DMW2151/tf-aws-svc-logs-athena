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
      Owner       = "terraform"
      Project     = "Test Service Logs -> Athena (ALB)"
    }
  }
}

// 
data "aws_caller_identity" "current" {}

// Resource: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet
resource "random_pet" "bucket" {}

// Create a temporary S3 bucket for testing...
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "svc_logs" {

  bucket        = "tf-athena-svc-logs-${random_pet.bucket.id}"
  acl           = "private"
  force_destroy = true // For testing, clearly...

  tags = {
    Name        = "tf-athena-svc-logs-${random_pet.bucket.id}"
    Environment = "Testing"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "allow_lb_logging" {
  bucket = aws_s3_bucket.svc_logs.id
  policy = data.aws_iam_policy_document.allow_lb_logging.json
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "allow_lb_logging" {

  // Allow Put Object into `arn:aws:s3:::bucket-name/prefix/AWSLogs/your-aws-account-id/*`
  // Principal -> Region Specific Agent/Account 
  statement {

    // See: Principal for each region:
    // https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
    principals {
      type        = "AWS"
      identifiers = [var.regional_lb_account_id]
    }

    effect = "Allow"

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.svc_logs.arn}/*"]
  }

  // Allow Put Object into `arn:aws:s3:::bucket-name/prefix/AWSLogs/your-aws-account-id/*`
  // Principal -> delivery.logs.amazonaws.com
  statement {

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.svc_logs.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }

  // Allow GetBucketACL on `arn:aws:s3:::bucket-name`
  // Principal -> delivery.logs.amazonaws.com
  statement {

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.svc_logs.arn]
  }

}

// Create a temporary Athena DB
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_database
resource "aws_athena_database" "svc_logs" {
  name   = "svc_logs"
  bucket = resource.aws_s3_bucket.svc_logs.bucket
}


module "svc_logs" {
  source = "../../"

  // Source Logs Location
  src_lb_logs_bucket = aws_s3_bucket.svc_logs.bucket
  src_lb_logs_prefix = ""

  // Athena & Glue Configuration
  src_athena_db_name    = aws_athena_database.svc_logs.name
  src_athena_table_name = "alb_001"

  organization_account_ids = [
    data.aws_caller_identity.current.id
  ]

}
