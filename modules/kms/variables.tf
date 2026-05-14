# ============================================================================
# KMS MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the KMS key module.
# Variables control key configuration, rotation, and access permissions.
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES
# ============================================================================

variable "app_id" {
  # 3rd segment of the organization naming convention: <prefix>-[np]-<app_id>-<env>-[label]
  description = "Application identifier (AppId) as registered in the your application catalog."
  type        = string
}

variable "environment" {
  # 4th segment of the organization naming convention. Drives the np segment automatically.
  description = "Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod)."
  type        = string

  validation {
    condition     = contains(["c", "t", "d", "s", "p"], var.environment)
    error_message = "environment must be one of: c (poc), t (test/sandbox), d (dev), s (stage), p (prod)."
  }
}

variable "label" {
  # Optional 5th segment of the organization naming convention.
  description = "Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a')."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name suffix for the KMS key (for example ebs, rds, secrets, s3-origin)"
  type        = string
  # Identifies the purpose of this key
  # Best practice: One key per use case for better security and auditing
  # Common names: ebs, rds, s3, secrets, ssm, logs, backup
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
  # Human-readable description shown in AWS console
  # Be specific about what this key encrypts
  # Example: "Encryption key for production EBS volumes"
}

# ============================================================================
# OPTIONAL VARIABLES - KEY CONFIGURATION
# ============================================================================

variable "deletion_window_in_days" {
  description = "Duration in days before key deletion (7-30 days)"
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
  # Safety period before permanent key deletion
  # During this window: key is disabled but can be recovered
  # After window: key permanently deleted (all encrypted data becomes inaccessible)
  # Recommendation: 30 days for production (maximum safety)
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
  # AWS automatically rotates key material every 365 days
  # Old key material retained for decryption of existing data
  # New encryptions use new key material
  # Transparent to applications (same key ID)
  # Recommended: Always enabled for production keys
}

variable "multi_region" {
  description = "Enable multi-region key"
  type        = bool
  default     = false
  # Multi-region keys: Single key ID usable in multiple regions
  # Use cases: Disaster recovery, global applications, cross-region backups
  # Cost: $1/month per region
}

# ============================================================================
# OPTIONAL VARIABLES - KEY POLICY
# ============================================================================

variable "key_administrators" {
  description = "List of IAM ARNs that can administer the key"
  type        = list(string)
  default     = []
  # Administrators can manage key lifecycle (modify policy, enable rotation, schedule deletion)
  # Administrators CANNOT encrypt/decrypt data (separation of duties)
  # Example: ["arn:aws:iam::123456789012:role/SecurityTeamRole"]
}

variable "key_users" {
  description = "List of IAM ARNs that can use the key (encrypt/decrypt)"
  type        = list(string)
  default     = []
  # Users can encrypt/decrypt data but cannot manage key lifecycle
  #
  # Common key users:
  # - EC2 instance IAM roles (for EBS encryption)
  # - Auto Scaling service role (for encrypted AMI/EBS)
  # - Application IAM roles (for S3, Secrets Manager)
  # - Lambda execution roles
  #
  # Example:
  # [
  #   "arn:aws:iam::123456789012:role/myapp-ec2-role",
  #   "arn:aws:iam::ACCOUNT:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  # ]
}

variable "allow_cloudwatch_logs" {
  description = "Allow CloudWatch Logs to use this key"
  type        = bool
  default     = false
  # Enables CloudWatch Logs to encrypt log data at rest
  # Required for: HIPAA, PCI-DSS compliance
  # Use when: Logs contain sensitive data (API keys, PII, credentials)
}

variable "service_principals" {
  description = "List of AWS service principals allowed to use the key (for example cloudfront.amazonaws.com)"
  type        = list(string)
  default     = []
  # Use this for AWS-managed service integrations that need direct key usage
  # Example: ["cloudfront.amazonaws.com"]
  # Keep the list short and explicit for least privilege
}

# ============================================================================
# TAGS
# ============================================================================

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
  # Tags for organization, cost allocation, and compliance
}
