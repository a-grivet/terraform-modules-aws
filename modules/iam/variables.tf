# ============================================================================
# IAM MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the IAM role and instance profile module.
# Variables control role configuration, managed policies, custom policies, and
# security boundaries.
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES - Must Be Provided
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
# IAM ROLE CONFIGURATION - Basic Role Settings
# ============================================================================

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = "IAM role for EC2 instances with SSM and CloudWatch access"
  # Human-readable description shown in AWS console
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds (1h to 12h)"
  type        = number
  default     = 3600
  # Maximum length of temporary credentials session (in seconds)
  #
  # Valid range: 3600 (1 hour) to 43200 (12 hours)
  # Default: 3600 seconds (1 hour)
}

variable "permissions_boundary_arn" {
  description = "ARN of the IAM Permissions Boundary to attach to the IAM Role."
  type        = string
  default     = "arn:aws:iam::xxxxxxxxxxxx:policy/OrgPermissionBoundary"
  # Replace xxxxxxxxxxxx with your AWS account ID
  # Replace OrgPermissionBoundary with your organization's permission boundary policy name
}

# ============================================================================
# AWS MANAGED POLICIES - Pre-Built Permission Sets
# ============================================================================

variable "enable_ssm" {
  description = "Enable AWS Systems Manager (SSM) access for Session Manager"
  type        = bool
  default     = true
  # Attach AmazonSSMManagedInstanceCore managed policy
}

variable "enable_cloudwatch" {
  description = "Enable CloudWatch Logs and Metrics access"
  type        = bool
  default     = true
  # Attach CloudWatchAgentServerPolicy managed policy
}

variable "managed_policy_arns" {
  description = "List of additional AWS managed policy ARNs to attach"
  type        = list(string)
  default     = []

  # Input validation: ensure valid IAM policy ARN format
  validation {
    condition = alltrue([
      for arn in var.managed_policy_arns : can(regex("^arn:aws:iam::(aws|[0-9]{12}):policy/", arn))
    ])
    error_message = "All managed policy ARNs must be valid AWS IAM policy ARNs"
  }
}

# ============================================================================
# CUSTOM INLINE POLICIES - Organization-Specific Permissions
# ============================================================================

variable "custom_policies" {
  description = "Map of custom inline policies (name -> policy JSON)"
  type        = map(string)
  default     = {}
}

# ============================================================================
# TAGS - Resource Organization and Cost Tracking
# ============================================================================

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
  # Tags for organization, cost allocation, and automation
}
