locals {
  // `src_s3_path` -> concat the source bucket and prefix to a full s3 path
  alb_src_s3_path = "s3://${var.svc_logs_bucket}/${var.alb_logs_prefix}"
  vpc_src_s3_path = "s3://${var.svc_logs_bucket}/${var.vpc_logs_prefix}"
  waf_src_s3_path = "s3://${var.svc_logs_bucket}/${var.waf_logs_prefix}"
}