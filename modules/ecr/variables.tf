# ============================================================================
# ECR MODULE - variables.tf
# ============================================================================
# Input variables for the ECR module.
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

# ============================================================================
# OPTIONAL VARIABLES - Image Configuration
# ============================================================================

variable "image_tag_mutability" {
  description = "Image tag mutability setting: MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE"
  }
}

variable "scan_on_push" {
  description = "Enable automatic image scanning for vulnerabilities when images are pushed"
  type        = bool
  default     = true
}

# ============================================================================
# OPTIONAL VARIABLES - Encryption Configuration
# ============================================================================

variable "encryption_type" {
  description = "Encryption type for images at rest: AES256 or KMS"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be either AES256 or KMS"
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for image encryption when encryption_type is KMS"
  type        = string
  default     = null
}

# ============================================================================
# OPTIONAL VARIABLES - Lifecycle Policy Configuration
# ============================================================================

variable "lifecycle_policy_max_image_count" {
  description = "Maximum number of tagged images to retain"
  type        = number
  default     = 10

  validation {
    condition     = var.lifecycle_policy_max_image_count > 0
    error_message = "Maximum image count must be greater than 0"
  }
}

variable "lifecycle_policy_untagged_days" {
  description = "Number of days to retain untagged images before deletion"
  type        = number
  default     = 7

  validation {
    condition     = var.lifecycle_policy_untagged_days > 0
    error_message = "Untagged image retention days must be greater than 0"
  }
}

variable "lifecycle_policy_tag_prefix_list" {
  description = "List of image tag prefixes to apply the lifecycle policy to"
  type        = list(string)
  default     = ["v", "release", "dev"]
}

# ============================================================================
# OPTIONAL VARIABLES - Repository Policy
# ============================================================================

variable "repository_policy_json" {
  description = "JSON-formatted ECR repository policy for custom permissions"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to repository resources"
  type        = map(string)
  default     = {}
}
