// Create a temporary S3 bucket for testing

// A testing bucket to sink our logs into
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "svc_logs" {

  // General
  bucket        = "tf-athena-svc-logs-${random_pet.random.id}"
  acl           = "private"
  force_destroy = true // Else this can fail with BucketNotEmpty

  // Tags
  tags = {
    Name        = "tf-athena-svc-logs-${random_pet.random.id}"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "allow_lb_logging" {
  bucket = aws_s3_bucket.svc_logs.id
  policy = data.aws_iam_policy_document.allow_lb_logging.json
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "allow_lb_logging" {

  // Policy Statements

  // Allow Put Object into `arn:aws:s3:::bucket-name/prefix/AWSLogs/your-aws-account-id/*`
  statement {

    // See: Principal for each region:
    // https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
    principals {
      type        = "AWS"
      identifiers = [
        var.regional_lb_account_id
      ]
    }

    effect = "Allow"

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.svc_logs.arn}/*"]
  }

  // Allow Put Object into `arn:aws:s3:::bucket-name/prefix/AWSLogs/your-aws-account-id/*`
  statement {

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.svc_logs.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }

  // Allow GetBucketACL on `arn:aws:s3:::bucket-name/prefix/AWSLogs/your-aws-account-id/`
  statement {

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.svc_logs.arn]
  }

}