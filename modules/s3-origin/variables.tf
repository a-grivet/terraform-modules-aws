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

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt bucket objects"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution allowed to access the origin"
  type        = string
}

# ============================================================================
# S3 LIFECYCLE CONFIGURATION
# ============================================================================

variable "noncurrent_version_expiration_days" {
  description = "Number of days to retain old object versions before deletion"
  type        = number
  default     = 30
}

variable "abort_incomplete_multipart_upload_days" {
  description = "Number of days after which incomplete multipart uploads are deleted"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
