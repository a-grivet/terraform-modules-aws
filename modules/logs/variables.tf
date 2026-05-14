# ============================================================================
# LOGS MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the CloudFront logs bucket module.
# The contract is intentionally small: naming, retention, and tagging.
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

# ============================================================================
# LOGS LIFECYCLE CONFIGURATION
# ============================================================================

variable "logs_retention_days" {
  description = "Number of days to retain CloudFront logs before deletion"
  type        = number
  default     = 90
  # 90 days is a practical default:
  # - long enough for troubleshooting and audit needs
  # - short enough to avoid indefinite storage growth
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
