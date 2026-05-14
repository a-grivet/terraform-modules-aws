# ============================================================================
# ALB MODULE OUTPUTS - outputs.tf
# ============================================================================
# This file defines output values that other modules or configurations can use.
# Outputs provide information about the ALB, target groups, listeners, and alarms.
#
# Why outputs matter:
# - Share ALB DNS name with Route53 module for domain configuration
# - Provide target group ARN to Auto Scaling Group module
# - Enable monitoring and troubleshooting with resource identifiers
# ============================================================================

# ============================================================================
# APPLICATION LOAD BALANCER OUTPUTS
# ============================================================================
# These outputs provide information about the main ALB resource

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.this.id
  # Unique identifier for the ALB resource
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
  # Full Amazon Resource Name (used for IAM policies, CloudWatch, etc.)
}

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer (for CloudWatch metrics)"
  value       = aws_lb.this.arn_suffix
  # Shortened version of ARN used in CloudWatch metrics
  # CloudWatch uses this to identify specific load balancers in metric dimensions
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
  # AWS-provided DNS name for the load balancer
  # You can access the ALB directly using this DNS name
  # Typically, you'll create a Route53 alias record pointing to this DNS name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer (for Route53 alias records)"
  value       = aws_lb.this.zone_id
  # AWS-managed Route53 hosted zone ID for the ALB
  # Required when creating Route53 alias records pointing to the ALB
}

# ============================================================================
# TARGET GROUP OUTPUTS
# ============================================================================
# These outputs provide information about the target group managing backend instances

output "target_group_id" {
  description = "ID of the primary target group"
  value       = aws_lb_target_group.primary.id
  # Unique identifier for the target group
}

output "target_group_arn" {
  description = "ARN of the primary target group (use this for ASG attachment)"
  value       = aws_lb_target_group.primary.arn
  # Full Amazon Resource Name for the target group
  # IMPORTANT: Auto Scaling Groups need this ARN to register instances automatically
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the primary target group (for CloudWatch metrics)"
  value       = aws_lb_target_group.primary.arn_suffix
  # Shortened version used in CloudWatch metrics
}

output "target_group_name" {
  description = "Name of the primary target group"
  value       = aws_lb_target_group.primary.name
  # Human-readable name of the target group
}

# ============================================================================
# LISTENER OUTPUTS
# ============================================================================
# These outputs provide information about HTTP and HTTPS listeners

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
  # ARN of the listener on port 80 (HTTP)
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
  # ARN of the listener on port 443 (HTTPS)
}

# ============================================================================
# CLOUDWATCH ALARM OUTPUTS
# ============================================================================
# These outputs provide information about monitoring alarms (if enabled)

output "unhealthy_targets_alarm_arn" {
  description = "ARN of the unhealthy targets CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.unhealthy_targets[0].arn : null
  # ARN of the alarm monitoring unhealthy backend instances
}

output "high_response_time_alarm_arn" {
  description = "ARN of the high response time CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.high_response_time[0].arn : null
  # ARN of the alarm monitoring slow response times
}

output "http_5xx_errors_alarm_arn" {
  description = "ARN of the 5xx errors CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.http_5xx_errors[0].arn : null
  # ARN of the alarm monitoring server errors (5xx status codes)
}

# ============================================================================
# CONVENIENCE OUTPUTS
# ============================================================================
# These outputs provide useful URLs and information for easy access

output "alb_url" {
  description = "URL to access the Application Load Balancer"
  value       = var.certificate_arn != "" ? "https://${aws_lb.this.dns_name}" : "http://${aws_lb.this.dns_name}"
  # Complete URL for accessing the load balancer
}
