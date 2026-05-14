# ============================================================================
# BACKEND MODULE - data.tf
# ============================================================================
# This file contains data sources and IAM policy documents for the Terraform
# backend infrastructure. The centralized backend uses:
# - S3 for remote state storage
# - S3 native lockfile support for state locking
# - KMS for encryption at rest
# ============================================================================

# ============================================================================
# AWS ACCOUNT IDENTITY - Current Account Information
# ============================================================================

# Get current AWS account ID for dynamic resource naming.
data "aws_caller_identity" "current" {}


# ============================================================================
# KMS KEY POLICY - Root Account Full Access
# ============================================================================
# This policy grants the AWS account root full access to the KMS key so
# permissions can then be delegated through IAM policies.

data "aws_iam_policy_document" "state_kms" {
  statement {
    sid = "default"
    actions = [
      "kms:*"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [
      aws_kms_key.terraform_state.arn
    ]
  }
}

# ============================================================================
# S3 BUCKET POLICY - Enforce HTTPS Only
# ============================================================================
# This policy denies all S3 operations over non-encrypted connections so state
# reads and writes happen over HTTPS only.

data "aws_iam_policy_document" "state_bucket_policy" {
  statement {
    sid     = "AllowOnlyHTTPS"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
  }
}
