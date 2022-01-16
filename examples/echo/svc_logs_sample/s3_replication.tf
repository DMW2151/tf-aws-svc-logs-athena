

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "replication" {

  name = "svc-logs-s3-replication-${data.aws_region.current.id}"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "s3.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
  })

  inline_policy {
    name = "svc-logs-replication"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "s3:GetReplicationConfiguration",
            "s3:ListBucket"
          ],
          "Effect" : "Allow",
          "Resource" : [
            "${aws_s3_bucket.svc_logs.arn}"
          ]
        },
        {
          "Action" : [
            "s3:GetObjectVersionForReplication",
            "s3:GetObjectVersionAcl",
            "s3:GetObjectVersionTagging"
          ],
          "Effect" : "Allow",
          "Resource" : [
            "${aws_s3_bucket.svc_logs.arn}/*"
          ]
        },
        {
          "Action" : [
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags"
          ],
          "Effect" : "Allow",
          "Resource" : [
            "${var.logging_bucket.arn}/*"
          ]
        }
      ]
    })
  }
}