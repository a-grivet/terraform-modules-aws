# ============================================================================
# LOGS MODULE - main.tf
# ============================================================================
# This module creates an S3 bucket dedicated to CloudFront access logs.
#
# What this module provides:
# - A dedicated S3 bucket for log storage
# - Public access fully blocked
# - Server-side encryption with SSE-S3 (AES256)
# - A lifecycle rule to expire old logs automatically
# - Ownership and ACL settings required for log delivery
#
# Why a dedicated logs bucket matters:
# - Keeps observability data separate from application content
# - Makes retention and cleanup policies easier to manage
# - Reduces accidental exposure of access logs
# ============================================================================

# Get current AWS account ID to make the bucket name globally unique.
data "aws_caller_identity" "current" {}

# ============================================================================
# LOGS BUCKET
# ============================================================================
# CloudFront log buckets need a globally unique name, so we suffix it with the
# AWS account ID. This keeps the naming deterministic across environments.

resource "aws_s3_bucket" "logs" {
  bucket = local.bucket_name

  tags = merge(
    var.tags,
    {
      Name = local.tag_name
    }
  )
}

# ============================================================================
# PUBLIC ACCESS BLOCK
# ============================================================================
# Access logs may contain sensitive request metadata, so we explicitly block any
# public ACL/policy path even if someone tries to open the bucket later.

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# SERVER-SIDE ENCRYPTION
# ============================================================================
# SSE-S3 is sufficient for standard CloudFront access logs and keeps the module
# simple while ensuring logs are encrypted at rest automatically.

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================================================
# LIFECYCLE CONFIGURATION
# ============================================================================
# Logs grow continuously over time, so automatic expiration keeps storage costs
# predictable without requiring manual cleanup.

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.logs_retention_days
    }
  }
}

# ============================================================================
# OWNERSHIP AND ACL
# ============================================================================
# CloudFront log delivery still relies on ACL-based delivery in many setups, so
# the bucket must allow the log delivery service to write objects correctly.

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  depends_on = [aws_s3_bucket_ownership_controls.logs]
  bucket     = aws_s3_bucket.logs.id
  acl        = "log-delivery-write"
}
