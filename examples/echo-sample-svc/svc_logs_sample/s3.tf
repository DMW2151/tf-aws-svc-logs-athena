// Create a temporary S3 bucket for testing

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "svc_logs" {

  // General
  bucket        = "tf-athena-svc-logs-${var.random}-${data.aws_region.current.id}"
  acl           = "private"
  force_destroy = true // Else this can fail with BucketNotEmpty on Destroy

  // Versioning
  versioning {
    enabled = true
  }

  // Lifecycle
  lifecycle {
    ignore_changes = [
      replication_configuration
    ]
  }

  // Tags
  tags = {
    Name = "tf-athena-svc-logs-${var.random}-${data.aws_region.current.id}"
  }
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "block" {

  bucket = aws_s3_bucket.svc_logs.id

  // Block All
  block_public_acls   = true
  block_public_policy = true

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
      type = "AWS"
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


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration
resource "aws_s3_bucket_replication_configuration" "allow_replication" {

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.svc_logs.id

  rule {
    id     = "replicate_all"
    status = "Enabled"

    destination {
      bucket        = var.logging_bucket.arn
      storage_class = "STANDARD"

      encryption_configuration {
        // Assumes KMS key in US-EAST-1; must be in same region as destination bucket; change as needed
        replica_kms_key_id = "arn:aws:kms:us-east-1:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

  }
}