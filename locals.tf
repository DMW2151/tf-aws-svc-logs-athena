locals {
  // `src_s3_path` -> concat the source bucket and prefix to a full s3 path
  src_s3_path = "s3://${var.src_lb_logs_bucket}/${var.src_lb_logs_prefix}"
}