# ============================================================================
# ROUTE53 MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines the inputs required to publish a custom domain name in
# Route 53 and map it to a CloudFront distribution.
# ============================================================================

variable "zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
  # Example: d111111abcdef8.cloudfront.net
}

variable "cloudfront_zone_id" {
  description = "CloudFront hosted zone ID (always Z2FDTNDATAQYW2)"
  type        = string
  default     = "Z2FDTNDATAQYW2"
  # CloudFront uses a fixed hosted zone ID for alias records.
}
