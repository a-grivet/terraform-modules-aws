# ============================================================================
# BACKEND MODULE - s3.tf
# ============================================================================
# This file creates the S3 bucket used to store Terraform state files.
# The bucket is configured with security best practices: encryption,
# versioning, public access blocking, and lifecycle management.
# ============================================================================

# ============================================================================
# S3 BUCKET - State Storage
# ============================================================================

# Primary storage location for Terraform state files. 
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.prefix}-terraform-backend-${var.region}-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

# ============================================================================
# PUBLIC ACCESS BLOCK - Prevent Public Exposure
# ============================================================================

# Block all public access to the bucket to ensure state files are not exposed.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# LIFECYCLE CONFIGURATION
# ============================================================================

# Automatically delete old state versions after 30 daysto save storage costs
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "delete-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ============================================================================
# VERSIONING - State History and Rollback
# ============================================================================

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================================================
# BUCKET POLICY - Enforce HTTPS Only access
# ============================================================================

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.state_bucket_policy.json
}

# ============================================================================
# SERVER-SIDE ENCRYPTION - Encrypt at Rest
# ============================================================================

# Enable server-side encryption using a KMS key to protect state files at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
