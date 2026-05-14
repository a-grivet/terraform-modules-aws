# ============================================================================
# ROUTE53 MODULE - main.tf
# ============================================================================
# This module creates Route 53 alias records for a static website fronted by
# CloudFront.
#
# What it creates:
# - One IPv4 alias record (A)
# - One IPv6 alias record (AAAA)
#
# Why both records matter:
# - The A record serves standard IPv4 clients
# - The AAAA record enables IPv6 connectivity
# - Both point to the same CloudFront distribution for dual-stack access
# ============================================================================

# ============================================================================
# WEBSITE DNS RECORD - IPV4
# ============================================================================
# Alias records point directly to AWS-managed targets without hardcoding IP
# addresses. This is the recommended way to expose CloudFront behind a custom
# domain in Route 53.


resource "aws_route53_record" "website" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
    # CloudFront is a global managed service, so target health evaluation is
    # not used here the same way it would be for an ALB/NLB alias record.
  }
}

# ============================================================================
# WEBSITE DNS RECORD - IPV6
# ============================================================================
# The AAAA record mirrors the A record so clients with IPv6 connectivity can
# reach the same CloudFront distribution without fallback complexity.

resource "aws_route53_record" "website_ipv6" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
