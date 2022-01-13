// Create Core VPC for dummy service and log the VPC flows

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "core" {

  // General
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  // Tags
  tags = {
    Name = "tf-svc-logs-core-vpc"
  }
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
resource "aws_flow_log" "logs" {

  // Logging Configuration - Log All Traffic to S3
  vpc_id               = aws_vpc.core.id
  log_destination      = data.aws_s3_bucket.logs_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
}