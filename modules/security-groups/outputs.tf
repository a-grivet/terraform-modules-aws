# ============================================================================
# SECURITY GROUPS MODULE OUTPUTS - outputs.tf
# ============================================================================
# This file defines output values for the Security Groups module.
# Outputs expose the identifiers that other modules need in order to attach or
# reference these security groups safely.
# ============================================================================

# ============================================================================
# ALB SECURITY GROUP OUTPUTS
# ============================================================================

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
  # Use to attach security group to the ALB.
  # Example: security_group_ids = [module.security_groups.alb_security_group_id]
}

output "alb_security_group_name" {
  description = "Name of the ALB security group"
  value       = aws_security_group.alb.name
}

output "alb_security_group_arn" {
  description = "ARN of the ALB security group"
  value       = aws_security_group.alb.arn
}

# ============================================================================
# APPLICATION SECURITY GROUP OUTPUTS
# ============================================================================

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
  # Canonical output name used by EC2/ASG-oriented consumers.
}

output "app_security_group_name" {
  description = "Name of the application security group"
  value       = aws_security_group.app.name
}

output "app_security_group_arn" {
  description = "ARN of the application security group"
  value       = aws_security_group.app.arn
}

# Compatibility aliases for ECS blueprint naming
output "app_sg_id" {
  description = "Compatibility alias for the application security group ID"
  value       = aws_security_group.app.id
  # Kept to ease migration of consumers that currently reference app_sg_id.
}

output "app_sg_name" {
  description = "Compatibility alias for the application security group name"
  value       = aws_security_group.app.name
}

output "app_sg_arn" {
  description = "Compatibility alias for the application security group ARN"
  value       = aws_security_group.app.arn
}

# ============================================================================
# DATABASE SECURITY GROUP OUTPUTS
# ============================================================================

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
  # Use to attach security group to RDS / Aurora clusters or instances.
}

output "db_security_group_name" {
  description = "Name of the database security group"
  value       = aws_security_group.db.name
}

output "db_security_group_arn" {
  description = "ARN of the database security group"
  value       = aws_security_group.db.arn
}

# ============================================================================
# REDIS SECURITY GROUP OUTPUTS
# ============================================================================

output "redis_security_group_id" {
  description = "ID of the Redis security group"
  value       = var.enable_redis ? aws_security_group.redis[0].id : null
  # Null when the cache tier is not part of the architecture.
}

output "redis_security_group_name" {
  description = "Name of the Redis security group"
  value       = var.enable_redis ? aws_security_group.redis[0].name : null
}

output "redis_security_group_arn" {
  description = "ARN of the Redis security group"
  value       = var.enable_redis ? aws_security_group.redis[0].arn : null
}

# ============================================================================
# CONVENIENCE OUTPUTS
# ============================================================================

output "all_security_group_ids" {
  description = "Map of all security group IDs"
  value = {
    alb   = aws_security_group.alb.id
    app   = aws_security_group.app.id
    db    = aws_security_group.db.id
    redis = var.enable_redis ? aws_security_group.redis[0].id : null
  }
  # Useful when a caller wants to inspect or forward every SG identifier at once.
}
