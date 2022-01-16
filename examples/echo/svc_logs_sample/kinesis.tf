// Define Kinesis Streams for WAF Delivery; WAF logs require a Kinesis Firehose delivery stream
// these logs get sunk into S3 every ~5 min

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream
resource "aws_kinesis_firehose_delivery_stream" "sink" {

  // General
  name        = "aws-waf-logs-sink"
  destination = "extended_s3"

  // Logs Configuration
  extended_s3_configuration {

    // Locations
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.svc_logs.arn

    // NOTE: WAF logs are slightly different than ALB or VPC logs; hardcoding some values here to 
    // sinking them to the same general format as other logs in tests
    //
    // Defaulting to `compression_format` == `GZIP` for parity w. VPC and ALB logs
    // Defaulting to `prefix` == `/AWSLogs/.../...` for parity w. VPC and ALB logs
    //
    compression_format = "GZIP" // Other supported values are UNCOMPRESSED, ZIP, Snappy, & HADOOP_SNAPPY. 
    prefix             = "AWSLogs/${data.aws_caller_identity.current.account_id}/webapplicationfirewall/${data.aws_region.current.id}/"

  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "kinesis" {

  // Allow Writing to the S3 Target
  statement {
    sid = "AllowS3"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.svc_logs.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.svc_logs.bucket}/*"
    ]
  }
}


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role 
resource "aws_iam_role" "firehose" {

  // General
  name_prefix = "tf-svc-logs-firehose"

  // Policy - Assume Firehose
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  // Policy - Allow S3 Puts
  inline_policy {
    name   = "kinesis-put"
    policy = data.aws_iam_policy_document.kinesis.json
  }

}
