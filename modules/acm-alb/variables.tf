# ============================================================================
# ACM MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the ACM certificate module.
# Variables control certificate configuration, validation, and monitoring.
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES - Must Be Provided
# ============================================================================
# These variables have no default value and must be set when using this module

variable "domain_name" {
  description = "Primary domain name for the certificate (e.g., app.example.com)"
  type        = string
  # This is the main domain that the certificate will protect
  # Example: "myapp.example.com" or "api.example.com"
}

variable "zone_name" {
  description = "Route53 hosted zone name for DNS validation (e.g., example.com)"
  type        = string
  # The parent domain where DNS validation records will be created
  # Example: If domain_name is "app.example.com", zone_name is "example.com"
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID (optional, use instead of zone_name for delegated zones)"
  type        = string
  default     = ""
  # Provide zone_id for better performance or when using delegated zones
  # If empty, the module will look up the zone using zone_name
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

variable "CostCenter" {
  description = "Cost center name for tracking costs"
  type        = string
  # Used for tracking costs
}


variable "validation_timeout" {
  description = "Timeout for certificate validation"
  type        = string
  default     = "45m"
  # How long to wait for AWS to validate the certificate via DNS
  # Format: number + unit (m=minutes, h=hours)
}

# ============================================================================
# CLOUDWATCH ALARM CONFIGURATION - Certificate Expiration Monitoring
# ============================================================================
# Optional monitoring for certificate expiration

variable "enable_expiry_alarm" {
  description = "Enable CloudWatch alarm for certificate expiry (useful for imported certificates)"
  type        = bool
  default     = false
  # When to enable:
  # - false (default): For DNS-validated certificates (they auto-renew)
  # - true: For imported certificates (they DON'T auto-renew, need manual renewal)
}

variable "expiry_alarm_threshold_days" {
  description = "Number of days before expiry to trigger alarm"
  type        = number
  default     = 30
  # Alert when certificate has fewer than this many days remaining
  # 30 days = plenty of time to renew or troubleshoot issues

  # Input validation: ensure value is reasonable
  validation {
    condition     = var.expiry_alarm_threshold_days > 0 && var.expiry_alarm_threshold_days <= 365
    error_message = "Expiry alarm threshold must be between 1 and 365 days."
  }
}

variable "acm_sns_topic_arn" {
  description = "SNS topic ARN for certificate expiry notifications"
  type        = string
  default     = ""
  # Provide an SNS topic ARN to receive email/SMS alerts when certificate is expiring
  # Empty string = no notifications (alarm still exists but doesn't notify anyone)
  # The SNS topic must already exist and have valid subscriptions
}

# ============================================================================
# TAGS - Resource Organization and Cost Tracking
# ============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  # Tags are key-value pairs attached to AWS resources
  # Used for organization, cost allocation, and automation
}
