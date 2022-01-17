variable "svc_logs_bucket_name" {
  type        = string
  default     = "tf-athena-svc-logs-profound-seagull"
  description = "location of the servie logs"
}

variable "aws_athena_database" {
  type = string
  description = "..."
  default = "aws_svc_logs"
}

variable "athena_query_results_bucket_name" {
  type        = string
  default     = "dmw2151-service-logs"
  description = "location of the servie logs"
}

variable "alb_logs_tbl_name" {
  type        = string
  description = "Athena table name for ALB logs"
  default     = "alb"
}