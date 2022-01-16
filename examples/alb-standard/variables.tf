variable "svc_logs_bucket_name" {
  type        = string
  default     = "tf-athena-svc-logs-profound-seagull"
  description = "location of the servie logs"
}

variable "athena_query_results_bucket_name" {
  type        = string
  default     = "dmw2151-service-logs"
  description = "location of the servie logs"
}