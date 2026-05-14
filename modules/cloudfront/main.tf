# ============================================================================
# CLOUDFRONT MODULE - main.tf
# ============================================================================
# This module creates a CloudFront distribution for a static website with:
# - Origin Access Control (OAC) for the private S3 origin
# - ACM certificate for HTTPS
# - access logging to S3
# - a response headers policy with common security headers
# ============================================================================

# ============================================================================
# ORIGIN ACCESS CONTROL (OAC)
# ============================================================================
# OAC is the modern way to let CloudFront access a private S3 bucket without
# exposing the bucket publicly.
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${local.name}-s3-oac"
  description                       = "OAC for S3 origin bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ============================================================================
# CLOUDFRONT DISTRIBUTION
# ============================================================================
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name} static website"
  default_root_object = var.default_root_object
  aliases             = [var.domain_name]
  price_class         = var.price_class

  # ===== ORIGIN CONFIGURATION =====
  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "S3-${var.s3_bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # ===== DEFAULT CACHE BEHAVIOR =====
  # The website serves static assets only, so a simple read-only cache
  # behavior is enough here.
  default_cache_behavior {
    target_origin_id       = "S3-${var.s3_bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = var.min_ttl
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl

    # Apply common security headers at the CDN edge.
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }

  # ===== CUSTOM ERROR RESPONSES =====
  # SPA-style websites often redirect 403/404 responses to index.html so the
  # client-side router can handle deep links.
  custom_error_response {
    error_code         = 404
    response_code      = var.error_404_response_code
    response_page_path = var.error_404_response_path
  }

  custom_error_response {
    error_code         = 403
    response_code      = var.error_403_response_code
    response_page_path = var.error_403_response_path
  }

  # ===== SSL/TLS CONFIGURATION =====
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.minimum_protocol_version
  }

  # ===== RESTRICTIONS =====
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ===== LOGGING =====
  # Access logs are sent to a dedicated S3 bucket for traffic analysis and
  # troubleshooting.
  logging_config {
    include_cookies = false
    bucket          = var.logs_bucket_domain_name
    prefix          = var.log_prefix
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-distribution"
    }
  )
}

# ============================================================================
# RESPONSE HEADERS POLICY - Security Headers
# ============================================================================
# This managed policy centralizes common browser-side protections for the
# static website.
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${local.name}-security-headers"
  comment = "Security headers for static website"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}
