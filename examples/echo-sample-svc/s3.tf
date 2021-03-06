// Create a Bucket for Sinking All Logs - Cross Region


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "svc_logs" {

  // General
  bucket        = "tf-athena-svc-logs-${random_pet.random.id}"
  acl           = "private"
  force_destroy = true // Else this can fail with BucketNotEmpty on Destroy

  // Versioning
  versioning {
    enabled = true
  }

  // Tags
  tags = {
    Name = "tf-athena-svc-logs-${random_pet.random.id}"
  }
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "block" {

  bucket = aws_s3_bucket.svc_logs.id

  // Block All
  block_public_acls   = true
  block_public_policy = true

}