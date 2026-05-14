# ============================================================================
# ACM MODULE OUTPUTS - outputs.tf
# ============================================================================
# This file defines output values that other modules or configurations can use.
# Outputs make information about the certificate available to parent modules.
#
# Why outputs matter:
# - Share certificate ARN with ALB/CloudFront (required for HTTPS)
# - Provide certificate details for monitoring and troubleshooting
# - Enable other modules to reference certificate information
# ============================================================================

# ============================================================================
# CERTIFICATE IDENTIFICATION OUTPUTS
# ============================================================================
# These outputs identify the certificate and are used by other AWS services

output "certificate_arn" {
  description = "ARN of the ACM certificate (use this for ALB/CloudFront)"
  value       = aws_acm_certificate_validation.this.certificate_arn
  # ARN (Amazon Resource Name): Unique identifier for the certificate
}

output "certificate_id" {
  description = "ID of the ACM certificate"
  value       = aws_acm_certificate.this.id
  # Certificate ID (shorter identifier, also the ARN)
  # Useful for API calls or terraform references
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.this.domain_name
  # The primary domain name this certificate protects
}

# ============================================================================
# CERTIFICATE STATUS OUTPUTS
# ============================================================================
# These outputs show the certificate's current state

output "certificate_status" {
  description = "Status of the certificate (should be ISSUED after validation)"
  value       = aws_acm_certificate.this.status
  # Possible values:
  # - "PENDING_VALIDATION": Waiting for DNS validation
  # - "ISSUED": Certificate is valid and ready to use
  # - "INACTIVE": Certificate has been revoked
  # - "EXPIRED": Certificate has expired
  # - "VALIDATION_TIMED_OUT": Validation failed (check DNS records)
}

# ============================================================================
# CERTIFICATE VALIDITY PERIOD OUTPUTS
# ============================================================================
# These outputs show when the certificate is valid
output "certificate_not_after" {
  description = "Expiration date of the certificate"
  value       = aws_acm_certificate.this.not_after
  # Timestamp when the certificate expires
  # For DNS-validated certificates, AWS renews before this date
}

output "certificate_not_before" {
  description = "Start date of the certificate validity period"
  value       = aws_acm_certificate.this.not_before
  # Timestamp when the certificate becomes valid
  # Usually the issuance date
}

# ============================================================================
# DNS VALIDATION OUTPUTS
# ============================================================================
# These outputs provide information about DNS validation

output "domain_validation_options" {
  description = "Domain validation options for the certificate"
  value       = aws_acm_certificate.this.domain_validation_options
  sensitive   = true
  # Contains DNS record details used for validation
  # Includes: domain_name, resource_record_name, resource_record_value, resource_record_type
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID used for DNS validation"
  value       = data.aws_route53_zone.this.zone_id
  # The Route53 zone where validation DNS records were created
}

output "validation_record_fqdns" {
  description = "List of FQDNs of DNS validation records"
  value       = [for record in aws_route53_record.validation : record.fqdn]
  # Fully Qualified Domain Names of all validation records created
}
