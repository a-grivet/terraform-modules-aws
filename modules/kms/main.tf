# ============================================================================
# KMS MODULE - main.tf
# ============================================================================
# This module creates and manages a customer-managed KMS (Key Management
# Service) key for encrypting data at rest in AWS services.
#
# What this module does:
# - Creates a customer-managed KMS key for data encryption
# - Configures automatic key rotation (annually)
# - Sets up a key policy controlling who can use/manage the key
# - Creates a human-friendly alias for easier key identification
#
# Common use cases:
# - EBS volumes: Encrypt EC2 instance disk storage
# - RDS databases: Encrypt database storage and backups
# - S3 buckets: Encrypt objects at rest
# - Secrets Manager: Encrypt passwords and sensitive data
# - Service integrations: Allow AWS services like CloudFront to use the key
# ============================================================================

# ============================================================================
# DATA SOURCES
# ============================================================================

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {}

# ============================================================================
# KMS KEY - Customer Managed Encryption Key
# ============================================================================

resource "aws_kms_key" "this" {
  description             = var.description             # Human-readable description
  deletion_window_in_days = var.deletion_window_in_days # 7-30 days safety window before permanent deletion
  enable_key_rotation     = var.enable_key_rotation     # Automatic annual rotation (recommended)
  multi_region            = var.multi_region            # Can replicate to other regions

  # Deletion window: 7-30 days before key is permanently deleted
  # During this period, you can cancel the deletion if needed
  # After deletion: All data encrypted with this key becomes permanently inaccessible

  # Key rotation: AWS automatically rotates key material every year
  # - Old key material is retained (can still decrypt old data)
  # - New encryptions use new key material
  # - Transparent to applications (same key ID)

  # Key policy defines WHO can do WHAT with this key.
  policy = data.aws_iam_policy_document.key_policy.json

  tags = merge(
    var.tags,
    {
      Name        = local.key_alias
      Environment = var.environment
      ManagedBy   = "terraform"
      Purpose     = var.key_name # ebs, rds, secrets, etc.
    }
  )
}

# ============================================================================
# KMS KEY ALIAS - Human-Friendly Key Name
# ============================================================================

resource "aws_kms_alias" "this" {
  name          = local.key_alias
  target_key_id = aws_kms_key.this.key_id

  # Alias provides a readable name instead of UUID key ID
  # Example: alias/myapp-prod-ebs instead of a1b2c3d4-5e6f-...
  # Can be used interchangeably with key ID in AWS APIs
}

# ============================================================================
# KEY POLICY - Define Key Permissions
# ============================================================================

data "aws_iam_policy_document" "key_policy" {
  # ===== STATEMENT 1: ROOT ACCOUNT ACCESS =====
  # Enables IAM policies to grant key permissions.
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"] # All KMS actions
    resources = ["*"]     # This key

    # Critical: This statement allows IAM policies to grant key access
    # Without it: Only key policy can control access (very inflexible)
    # With it: Both key policy AND IAM policies work together
  }

  # ===== STATEMENT 2: KEY ADMINISTRATORS =====
  # Grant administrative permissions to manage the key.
  dynamic "statement" {
    for_each = length(var.key_administrators) > 0 ? [1] : []

    content {
      sid    = "AllowKeyAdministrators"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_administrators # List of IAM role/user ARNs
      }

      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
      ]

      resources = ["*"]

      # Administrative actions: manage key lifecycle
      # Note: Does NOT include encrypt/decrypt (separation of duties)
    }
  }

  # ===== STATEMENT 3: KEY USERS =====
  # Grant permissions to use the key for encryption/decryption.
  dynamic "statement" {
    for_each = length(var.key_users) > 0 ? [1] : []

    content {
      sid    = "AllowKeyUsage"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_users # List of IAM role ARNs (EC2 roles, service roles)
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*", # Used for envelope encryption
        "kms:DescribeKey",
      ]

      resources = ["*"]

      # Cryptographic actions: encrypt/decrypt data
    }

    # Envelope encryption (GenerateDataKey):
    # 1. Service calls GenerateDataKey -> gets plaintext + encrypted data key
    # 2. Service encrypts data with plaintext key (locally)
    # 3. Service stores encrypted data + encrypted key together
    # 4. Service discards plaintext key (never stored)
    # 5. To decrypt: Service sends encrypted key to KMS for decryption
  }

  # ===== STATEMENT 4: GRANT PERMISSIONS =====
  # Allow key users to create grants for AWS services.
  dynamic "statement" {
    for_each = length(var.key_users) > 0 ? [1] : []

    content {
      sid    = "AllowAttachmentOfPersistentResources"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_users
      }

      actions = [
        "kms:CreateGrant", # Create grant (delegate permissions)
        "kms:ListGrants",
        "kms:RevokeGrant",
      ]

      resources = ["*"]
      # CRITICAL CONDITION: Only for AWS services
      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }

      # Ensures grants are only created for AWS services (Auto Scaling, RDS, etc.)
      # Prevents arbitrary grant creation
    }

    # Grants are temporary, delegated permissions used by AWS services
    # Example: Auto Scaling creates a grant to decrypt encrypted AMI snapshots
  }

  # ===== STATEMENT 5: CLOUDWATCH LOGS =====
  # Allow CloudWatch Logs service to use this key.
  dynamic "statement" {
    for_each = var.allow_cloudwatch_logs ? [1] : []

    content {
      sid    = "AllowCloudWatchLogs"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["logs.${data.aws_partition.current.dns_suffix}"]
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey",
      ]

      resources = ["*"]

      # CRITICAL CONDITION: Only CloudWatch Logs in this account
      condition {
        test     = "ArnLike"
        variable = "kms:EncryptionContext:aws:logs:arn"
        values   = ["arn:${data.aws_partition.current.partition}:logs:*:${data.aws_caller_identity.current.account_id}:*"]
      }
    }
  }

  # ===== STATEMENT 6: SERVICE PRINCIPALS =====
  # Allow selected AWS services to use the key.
  dynamic "statement" {
    for_each = length(var.service_principals) > 0 ? [1] : []

    content {
      sid    = "AllowServicePrincipals"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = var.service_principals
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey",
      ]

      resources = ["*"]

      # Service principals cover AWS-managed integrations such as CloudFront
      # Keep this list explicit to avoid over-permissive key usage
    }
  }
}
