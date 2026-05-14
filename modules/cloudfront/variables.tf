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

variable "domain_name" {
  description = "Custom domain name for the CloudFront distribution"
  type        = string
}

variable "s3_bucket_id" {
  description = "ID of the S3 origin bucket"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 origin bucket"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate used for HTTPS"
  type        = string
}

variable "logs_bucket_domain_name" {
  description = "Domain name of the S3 bucket receiving CloudFront logs"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

# ============================================================================
# CLOUDFRONT BEHAVIOR CONFIGURATION
# ============================================================================

variable "default_root_object" {
  description = "Default file to serve, typically index.html"
  type        = string
  default     = "index.html"
}

variable "min_ttl" {
  description = "Minimum cache time to live in seconds"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default cache time to live in seconds"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum cache time to live in seconds"
  type        = number
  default     = 86400
}

# ============================================================================
# SSL/TLS CONFIGURATION
# ============================================================================

variable "minimum_protocol_version" {
  description = "Minimum TLS version accepted for viewer HTTPS connections"
  type        = string
  default     = "TLSv1.2_2021"
}

# ============================================================================
# LOGGING CONFIGURATION
# ============================================================================

variable "log_prefix" {
  description = "Prefix for CloudFront log files written to S3"
  type        = string
  default     = "cloudfront/"
}

# ============================================================================
# ERROR PAGES CONFIGURATION
# ============================================================================

variable "error_404_response_code" {
  description = "HTTP response code returned for 404 errors"
  type        = number
  default     = 200
}

variable "error_404_response_path" {
  description = "Path returned to users for 404 errors"
  type        = string
  default     = "/index.html"
}

variable "error_403_response_code" {
  description = "HTTP response code returned for 403 errors"
  type        = number
  default     = 200
}

variable "error_403_response_path" {
  description = "Path returned to users for 403 errors"
  type        = string
  default     = "/index.html"
}

variable "tags" {
  description = "Common tags applied to CloudFront resources"
  type        = map(string)
  default     = {}
}
