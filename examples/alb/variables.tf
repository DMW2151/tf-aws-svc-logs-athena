variable "regional_lb_account_id" {
  type        = string
  default     = "127311923021" // AWS Load Balancer Account ID for US-EAST-1
  description = "Account ID of the Elastic (or Application) Load Balancer. Refer to AWS load-balancer-access-logs docs."
}