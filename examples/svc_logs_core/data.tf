
data "aws_s3_bucket" "logs_bucket" {
  bucket = var.logging_bucket
}