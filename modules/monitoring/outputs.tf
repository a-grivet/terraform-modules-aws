# ============================================================================
# MONITORING MODULE OUTPUTS - outputs.tf
# ============================================================================
# Outputs focus on the common artifacts created by the monitoring foundation.
# Consumers can then wire these values into additional dashboards, alarms, or
# operational tooling if needed.
# ============================================================================

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alert notifications"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic used for alert notifications"
  value       = aws_sns_topic.alerts.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard, when dashboard creation is enabled"
  value       = try(aws_cloudwatch_dashboard.main[0].dashboard_name, null)
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard, when dashboard creation is enabled"
  value       = try(aws_cloudwatch_dashboard.main[0].dashboard_arn, null)
}

output "dashboard_url" {
  description = "URL to open the CloudWatch dashboard in the AWS Console, when dashboard creation is enabled"
  value       = try("https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}", null)
}

output "alarm_arns" {
  description = "Map of CloudWatch alarm ARNs keyed by normalized alarm identifier"
  value = {
    for alarm_key, alarm in aws_cloudwatch_metric_alarm.this :
    alarm_key => alarm.arn
  }
}

output "alarm_names" {
  description = "Map of CloudWatch alarm names keyed by normalized alarm identifier"
  value = {
    for alarm_key, alarm in aws_cloudwatch_metric_alarm.this :
    alarm_key => alarm.alarm_name
  }
}

output "monitoring_summary" {
  description = "High-level summary of the monitoring configuration"
  value = {
    dashboard_enabled      = var.create_dashboard
    alarms_enabled         = var.enable_alarms
    alarm_count            = length(aws_cloudwatch_metric_alarm.this)
    sns_topic_arn          = aws_sns_topic.alerts.arn
    alert_email_configured = trimspace(var.alert_email) != ""
    dashboard_name         = try(aws_cloudwatch_dashboard.main[0].dashboard_name, null)
    dashboard_url          = try("https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}", null)
  }
}
