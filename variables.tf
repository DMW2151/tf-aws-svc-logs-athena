// S3 Logs...
variable "src_lb_logs_bucket" {
  type        = string
  description = "Path of the Source ALB logs..."
}

variable "src_lb_logs_prefix" {
  type        = string
  description = "Path of the Source ALB logs..."
  default     = ""

  validation {
    condition     = var.src_lb_logs_prefix == "" ? true : regex("/$", var.src_lb_logs_prefix)
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }

}

// Athena Source and Destination
variable "src_athena_db_name" {
  type        = string
  description = "Athena DB to place Table into..."
}

variable "src_athena_table_name" {
  type        = string
  description = "Path of the Source ALB logs..."
}

