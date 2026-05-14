# ============================================================================
# SECRETS MANAGER MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the Secrets Manager module.
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

variable "secret_name" {
  description = "Name suffix for the secret (e.g., 'db-password', 'api-key')"
  type        = string
  # Examples: db-master-password, api-key-stripe, oauth-client-secret
}

# ============================================================================
# OPTIONAL VARIABLES - SECRET CONFIGURATION
# ============================================================================

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = "Secret managed by Terraform"
}

variable "kms_key_id" {
  description = "KMS key ID for encrypting the secret (leave empty for default)"
  type        = string
  default     = ""
  # Empty: Use default aws/secretsmanager key (free)
  # Provide ARN: Use customer-managed key (module.kms_secrets.key_arn)
}

variable "recovery_window_in_days" {
  description = "Days to retain secret before permanent deletion (0 for immediate)"
  type        = number
  default     = 7

  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "Recovery window must be 0 (immediate) or 7-30 days."
  }
  # Recommendation: 7 days (dev), 30 days (prod)
}

# ============================================================================
# OPTIONAL VARIABLES - PASSWORD GENERATION
# ============================================================================

variable "create_random_password" {
  description = "Generate random password (true) or use provided value (false)"
  type        = bool
  default     = true
}

variable "password_length" {
  description = "Length of generated password"
  type        = number
  default     = 32

  validation {
    condition     = var.password_length >= 16 && var.password_length <= 128
    error_message = "Password length must be between 16 and 128 characters."
  }
}

variable "secret_value" {
  description = "Secret value to store (required if create_random_password is false)"
  type        = string
  default     = ""
  sensitive   = true
  # Used only when create_random_password = false
}

# ============================================================================
# OPTIONAL VARIABLES - ROTATION
# ============================================================================

variable "enable_rotation" {
  description = "Enable automatic secret rotation"
  type        = bool
  default     = false
  # Requires: rotation_lambda_arn
}

variable "rotation_lambda_arn" {
  description = "ARN of Lambda function for secret rotation"
  type        = string
  default     = ""
  # Required when enable_rotation = true
  # Lambda must have permissions to update secret and target service
}

variable "rotation_days" {
  description = "Number of days between automatic rotations"
  type        = number
  default     = 30

  validation {
    condition     = var.rotation_days >= 1 && var.rotation_days <= 365
    error_message = "Rotation days must be between 1 and 365."
  }
  # Recommendations: 30 days (standard), 7 days (high security)
}

# ============================================================================
# TAGS
# ============================================================================

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
