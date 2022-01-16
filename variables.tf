// S3 Logs Bucket - Location of logs emitted from AWS services
variable "src_lb_logs_bucket" {
  type        = string
  description = "The name of the S3 bucket."
}

// S3 Source Locations - Location of logs emitted from AWS services; NOTE that ${bucket}/${prefix} 
// defines the root of the AWS logs, i.e. this is the root directory the AWS logs are located
//
// Full Path `${bucket}/${prefix}/AWSLogs/${aws-account-id}/${service-name}/region/yyyy/mm/dd/`
variable "src_lb_logs_prefix" {
  type        = string
  description = "The prefix (logical hierarchy) in the bucket. If you don't specify a prefix, assumes the logs are placed at the root level of the bucket."
  default     = ""

  validation {
    condition     = var.src_lb_logs_prefix == "" ? true : regex("/$", var.src_lb_logs_prefix)
    error_message = "The src_lb_logs_prefix value must be a valid folder prefix, ending with '/'."
  }

}

// Projected Partitioning Variables

// organization_enabled_regions -> which regions are included in this table?
variable "organization_enabled_regions" {
  type        = list(string)
  description = "AWS regions to include in this table, these regions are included in projected partitioning"
  default = [
    "ap-northeast-1",
    "ap-northeast-2",
    "ap-northeast-3",
    "ap-south-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ca-central-1",
    "eu-central-1",
    "eu-north-1",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "sa-east-1",
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2"
  ]
}

// organization_account_ids -> which accounts are included in this table?
variable "organization_account_ids" {
  type        = list(string)
  description = "Account IDs to include in this table, these account IDs are included in projected partitioning"
  default = []
}

// Athena Variables

// Athena DB -  
variable "src_athena_db_name" {
  type        = string
  description = "Athena DB for all"
}

// Glue Catalog
variable "src_athena_catalog_id" {
  type        = string
  description = "Path of the Source ALB logs..."
  default     = "default"
}

// Service Logs Tables
variable "src_athena_table_alb_name" {
  type        = string
  description = "Athena table name for ALB logs"
  default     = "alb"
}

variable "src_athena_table_waf_name" {
  type        = string
  description = "Athena table name for WAF logs"
  default     = "waf"
}

variable "src_athena_table_vpc_name" {
  type        = string
  description = "Athena table name for VPC Flow logs"
  default     = "vpcflow"
}
