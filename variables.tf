// S3 Logs...
variable "src_lb_logs_bucket" {
  type        = string
  description = "The name of the S3 bucket."
}

// S3 Logs...
variable "src_lb_logs_prefix" {
  type        = string
  description = "The prefix (logical hierarchy) in the bucket. If you don't specify a prefix, assumes the logs are placed at the root level of the bucket."
  default     = ""

  validation {
    condition     = var.src_lb_logs_prefix == "" ? true : regex("/$", var.src_lb_logs_prefix)
    error_message = "The src_lb_logs_prefix value must be a valid folder prefix, ending with '/'."
  }

}

variable "organization_enabled_regions" {
  type        = list(string)
  description = "..."
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

// Athena Source...
variable "src_athena_db_name" {
  type        = string
  description = "Athena DB to place Table into..."
}

// Athena Source...
variable "src_athena_table_name" {
  type        = string
  description = "Path of the Source ALB logs..."
}

// Athena Extras
variable "src_athena_catalog_id" {
  type        = string
  description = "Path of the Source ALB logs..."
  default     = "default"
}

variable "organization_account_ids" {
  type        = list(string)
  description = "Associated account IDs -> Used for Projected Partitioning"
}
