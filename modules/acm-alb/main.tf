# ============================================================================
# AWS CERTIFICATE MANAGER (ACM) MODULE - main.tf
# ============================================================================
# This module creates and manages SSL/TLS certificates for secure HTTPS communication.
#
# What this module does:
# - Creates an SSL/TLS certificate for your domain name(s)
# - Automatically validates certificate ownership via DNS records in Route53
# - Handles certificate renewal automatically
#
# How it works:
# 1. Request certificate from AWS Certificate Manager
# 2. AWS provides DNS validation records (CNAME records)
# 3. Module automatically creates these records in Route53
# 4. AWS verifies ownership and issues the certificate
# 5. Certificate auto-renews before expiration
# ============================================================================

# ============================================================================
# DATA SOURCES
# ============================================================================

# Look up the Route53 hosted zone for DNS validation
# This zone must already exist - it's where the validation DNS records will be created
data "aws_route53_zone" "this" {
  zone_id      = var.zone_id != "" ? var.zone_id : null   # Use zone_id if provided
  name         = var.zone_id == "" ? var.zone_name : null # Otherwise, use zone_name to look up
  private_zone = false                                    # We need a public zone (internet-accessible)
}

# ============================================================================
# ACM CERTIFICATE - Request SSL/TLS Certificate
# ============================================================================
# This resource requests a new certificate from AWS Certificate Manager

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name # Primary domain
  validation_method = "DNS"           # Use DNS validation (automatic via Route53)

  # Certificate lifecycle management
  lifecycle {
    create_before_destroy = true # Create new certificate before deleting old one (zero downtime)
    # This ensures your application continues working during certificate renewal
  }

  # Tags for resource organization and cost tracking
  tags = merge(
    var.tags, # Include custom tags passed from parent module
    {
      Name        = var.domain_name # Certificate name for identification
      Environment = var.environment # Environment identifier (dev, staging, prod)
      CostCenter  = var.CostCenter  # Department for cost tracking
      ManagedBy   = "Terraform"     # Indicates this resource is managed by Terraform
    }
  )
}

# ============================================================================
# DNS VALIDATION RECORDS - Prove Domain Ownership
# ============================================================================
# AWS requires DNS records to prove you own the domain before issuing the certificate

# Create DNS validation records in Route53
resource "aws_route53_record" "validation" {
  # Use for_each to create one record per domain
  # This is a Terraform "for loop" that iterates over domain_validation_options
  # 
  # How it works:
  # - "dvo" = temporary variable name (short for "Domain Validation Option")
  # - AWS provides domain_validation_options list with DNS record details for each domain
  # - The loop creates one Route53 record per domain in the certificate
  # 
  # Example: If certificate covers "app.example.com" + "*.example.com", this creates 2 DNS records
  # Use for_each to create one record per domain

  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name  # CNAME record name provided by AWS
      record = dvo.resource_record_value # CNAME record value provided by AWS
      type   = dvo.resource_record_type  # Record type (typically CNAME)
    }
  }

  allow_overwrite = true                               # Allow updating existing records (useful for certificate renewals)
  name            = each.value.name                    # DNS record name
  records         = [each.value.record]                # DNS record value
  ttl             = 60                                 # Time-to-live: 60 seconds (how long DNS servers cache this record)
  type            = each.value.type                    # Record type (CNAME)
  zone_id         = data.aws_route53_zone.this.zone_id # Route53 zone where record is created
}

# ============================================================================
# CERTIFICATE VALIDATION
# ============================================================================
# This resource waits for AWS to validate the domain and issue the certificate

# Wait for certificate validation to complete before proceeding
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn                                # Certificate to validate
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn] # DNS records to check

  # Validation process:
  # 1. AWS checks if the DNS records exist and match expected values
  # 2. Once verified, AWS issues the certificate
  # 3. This resource completes, allowing dependent resources (like ALB) to proceed

  timeouts {
    create = var.validation_timeout # Maximum time to wait
  }
}

# ============================================================================
# CLOUDWATCH ALARMS - Monitor Certificate Expiration
# ============================================================================
# Optional monitoring for certificate expiration (mainly for imported certificates)

# Alarm triggers when certificate is about to expire
resource "aws_cloudwatch_metric_alarm" "certificate_expiry" {
  count = var.enable_expiry_alarm ? 1 : 0 # Create alarm only if enabled

  alarm_name          = "${var.domain_name}-certificate-expiry"
  comparison_operator = "LessThanThreshold"             # Alert when days to expiry < threshold
  evaluation_periods  = 1                               # Alert after 1 evaluation period
  metric_name         = "DaysToExpiry"                  # AWS metric: number of days until certificate expires
  namespace           = "AWS/CertificateManager"        # AWS service namespace
  period              = 86400                           # Check once per day (86400 seconds = 24 hours)
  statistic           = "Minimum"                       # Use minimum value during the period
  threshold           = var.expiry_alarm_threshold_days # Alert when days < default value : 30
  alarm_description   = "Certificate ${var.domain_name} expiring soon"
  treat_missing_data  = "notBreaching" # Don't alarm if data is missing

  # Why this matters:
  # - DNS-validated certificates auto-renew (this alarm is just extra safety)
  # - Imported certificates DON'T auto-renew (this alarm is critical)

  # Identify which certificate to monitor
  dimensions = {
    CertificateArn = aws_acm_certificate.this.arn
  }

  # Send notifications to SNS topic
  alarm_actions = var.acm_sns_topic_arn != "" ? [var.acm_sns_topic_arn] : [] # Alert when threshold breached
  ok_actions    = var.acm_sns_topic_arn != "" ? [var.acm_sns_topic_arn] : [] # Alert when back to normal

  # Tags for organization
  tags = merge(
    var.tags,
    {
      Name        = "${var.domain_name}-certificate-expiry-alarm"
      Environment = var.environment
    }
  )
}
