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
  type = list(string)
  description = "Associated account IDs -> Used for Projected Partitioning"
}
