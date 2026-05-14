# ============================================================================
# SECRETS MANAGER MODULE - main.tf
# ============================================================================
# This module creates and manages secrets in AWS Secrets Manager.
# Primary use case: Storing database passwords securely.
#
# What this module does:
# - Generates a random password (optional) or uses provided value
# - Stores the secret encrypted in Secrets Manager
# - Configures optional automatic rotation
# ============================================================================

# ============================================================================
# RANDOM PASSWORD GENERATION
# ============================================================================

resource "random_password" "master_password" {
  count = var.create_random_password ? 1 : 0

  length  = var.password_length # Default: 32 characters
  special = true

  # Exclude problematic characters for connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
  # Excluded: @, ', ", `, /, \, |, ;, comma

  # Complexity requirements
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 2
}

# ============================================================================
# SECRETS MANAGER SECRET
# ============================================================================

resource "aws_secretsmanager_secret" "this" {
  name_prefix             = local.name_prefix
  description             = var.description
  kms_key_id              = var.kms_key_id              # Custom KMS key or empty for default
  recovery_window_in_days = var.recovery_window_in_days # 7-30 days before permanent deletion

  # name_prefix adds random suffix for safe recreation

  tags = merge(
    var.tags,
    {
      Name        = "sm-${local.base}-${var.secret_name}${local.label_suffix}"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# ============================================================================
# SECRET VERSION (ACTUAL VALUE)
# ============================================================================

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id

  # Use generated password or provided value
  secret_string = var.create_random_password ? random_password.master_password[0].result : var.secret_value

  # Secret can be plain text or JSON format
  # JSON example: {"username":"admin","password":"xyz","host":"db.example.com"}
}

# ============================================================================
# OPTIONAL: SECRET ROTATION
# ============================================================================

resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days # Default: 30 days
  }

  depends_on = [aws_secretsmanager_secret_version.this]

  # Rotation requires:
  # - Lambda function to perform password change
  # - Network access from Lambda to database
  # - Proper IAM permissions
}
