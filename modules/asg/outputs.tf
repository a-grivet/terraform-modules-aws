# ============================================================================
# ASG MODULE OUTPUTS - outputs.tf
# ============================================================================
# Outputs expose identifiers and monitoring references that other modules use,
# especially the monitoring stack and ALB integrations.
# ============================================================================

# ============================================================================
# LAUNCH TEMPLATE OUTPUTS
# ============================================================================

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.this.id
}

output "launch_template_arn" {
  description = "ARN of the Launch Template"
  value       = aws_launch_template.this.arn
}

output "launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.this.latest_version
}

# ============================================================================
# AUTO SCALING GROUP OUTPUTS
# ============================================================================

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.arn
}

# ============================================================================
# AUTO SCALING GROUP CAPACITY OUTPUTS
# ============================================================================

output "autoscaling_group_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.min_size
}

output "autoscaling_group_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.max_size
}

output "autoscaling_group_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.desired_capacity
}

output "autoscaling_group_availability_zones" {
  description = "Availability zones used by the Auto Scaling Group"
  value       = aws_autoscaling_group.this.availability_zones
}

# ============================================================================
# SCALING POLICY OUTPUTS
# ============================================================================

output "cpu_scaling_policy_arn" {
  description = "ARN of the CPU target tracking scaling policy"
  value       = var.enable_cpu_target_tracking ? aws_autoscaling_policy.cpu_target_tracking[0].arn : null
}

output "alb_scaling_policy_arn" {
  description = "ARN of the ALB target tracking scaling policy"
  value       = var.enable_alb_target_tracking && var.target_group_arns != null ? aws_autoscaling_policy.alb_target_tracking[0].arn : null
}

# ============================================================================
# CLOUDWATCH ALARM OUTPUTS
# ============================================================================

output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : null
}

output "low_cpu_alarm_arn" {
  description = "ARN of the low CPU CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.low_cpu[0].arn : null
}

# ============================================================================
# COMPATIBILITY OUTPUTS
# ============================================================================

output "asg_name" {
  description = "Name of the Auto Scaling Group (alias for autoscaling_group_name)"
  value       = aws_autoscaling_group.this.name
}
