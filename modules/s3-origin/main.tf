# ============================================================================
# S3 ORIGIN MODULE - main.tf
# ============================================================================
# This module creates a private S3 bucket used as the CloudFront origin.
# Access is restricted to CloudFront through Origin Access Control (OAC).
# ============================================================================

# Get current AWS account ID to keep bucket names globally unique.
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "origin" {
  bucket = local.bucket_name

  tags = merge(
    var.tags,
    {
      Name = local.tag_name
    }
  )
}

# ============================================================================
# PUBLIC ACCESS BLOCK - Maximum Security
# ============================================================================
# The origin bucket must stay private because CloudFront is the only entry
# point expected to read content from it.
resource "aws_s3_bucket_public_access_block" "origin" {
  bucket = aws_s3_bucket.origin.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# VERSIONING - Content History
# ============================================================================
# Versioning helps recover previous object states and works with lifecycle
# rules to clean up old versions automatically.
resource "aws_s3_bucket_versioning" "origin" {
  bucket = aws_s3_bucket.origin.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================================================
# ENCRYPTION - KMS CMK
# ============================================================================
# The bucket stores objects encrypted with the customer-managed KMS key passed
# by the environment configuration.
resource "aws_s3_bucket_server_side_encryption_configuration" "origin" {
  bucket = aws_s3_bucket.origin.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

# ============================================================================
# LIFECYCLE POLICY - Cost Optimization
# ============================================================================
# Cleanup rules keep bucket storage under control without impacting the current
# object version served by CloudFront.
resource "aws_s3_bucket_lifecycle_configuration" "origin" {
  bucket = aws_s3_bucket.origin.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }
  }
}

# ============================================================================
# BUCKET POLICY - CloudFront OAC Access Only
# ============================================================================
# The bucket policy grants CloudFront read access for this distribution only
# and blocks any insecure transport request.
resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.origin_policy.json

  depends_on = [aws_s3_bucket_public_access_block.origin]
}

data "aws_iam_policy_document" "origin_policy" {
  # Allow CloudFront OAC to read objects from this origin bucket.
  statement {
    sid    = "AllowCloudFrontOAC"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.origin.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_distribution_arn]
    }
  }

  # Deny non-SSL requests to enforce encrypted transport.
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.origin.arn,
      "${aws_s3_bucket.origin.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
