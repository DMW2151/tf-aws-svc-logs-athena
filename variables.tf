// Athena DB Configuration

variable "athena_db_name" {
  type        = string
  description = ""
  default     = "default"
}

variable "athena_catalog_id" {
  type        = string
  description = "Path of the Source ALB logs..."
  default     = "default"
}


// Source Logs Bucket

variable "svc_logs_bucket" {
  type        = string
  description = "The name of the S3 bucket."
}


// S3 Source Locations - Location of logs emitted from AWS services

variable "alb_logs_prefix" {
  type        = string
  description = "The prefix in the bucket. If you don't specify a prefix, assumes the logs are placed at the root level of the bucket."
  default     = ""

  validation {
    condition     = (var.alb_logs_prefix == "") ? true : !(regex("/$", var.alb_logs_prefix) == "")
    error_message = "The alb_logs_prefix value must be a valid folder prefix, ending with '/'."
  }

}

variable "vpc_logs_prefix" {
  type        = string
  description = "The prefix in the bucket. If you don't specify a prefix, assumes the logs are placed at the root level of the bucket."
  default     = ""

  validation {
    condition     = (var.vpc_logs_prefix == "") ? true : !(regex("/$", var.vpc_logs_prefix) == "")
    error_message = "The src_lb_logs_prefix value must be a valid folder prefix, ending with '/'."
  }

}

variable "waf_logs_prefix" {
  type        = string
  description = "The prefix in the bucket. If you don't specify a prefix, assumes the logs are placed at the root level of the bucket."
  default     = ""

  validation {
    condition     = (var.waf_logs_prefix == "") ? true : !(regex("/$", var.waf_logs_prefix) == "")
    error_message = "The src_lb_logs_prefix value must be a valid folder prefix, ending with '/'."
  }

}

// Athena - Service Logs Table Names

// Service Logs Tables
variable "alb_logs_tbl_name" {
  type        = string
  description = "Athena table name for ALB logs"
  default     = "alb"
}

variable "vpc_logs_tbl_name" {
  type        = string
  description = "Athena table name for VPC logs"
  default     = "vpc"
}

variable "waf_logs_tbl_name" {
  type        = string
  description = "Athena table name for WAF Flow logs"
  default     = "waf"
}


// Athena - Extra Variables - Enable Projected Partitioning
variable "enable_projected_partitions" {
  type        = bool
  description = "Enable Projected Partioning?"
  default     = true
}

// Partition Filtering - See: https://aws.amazon.com/about-aws/whats-new/2021/11/amazon-athena-queries-aws-glue-data-catalog-partition-indexes/
variable "enable_partition_filtering" {
  type        = bool
  description = "Enable Projected Partioning?"
  default     = false
}

// Athena - Extra Variables - Projected Partitioning

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
  default     = []
}

