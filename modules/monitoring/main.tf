# ============================================================================
# CLOUDWATCH MONITORING MODULE - main.tf
# ============================================================================
# This module provides a reusable monitoring foundation for Terraform
# blueprints. The module owns the common infrastructure pieces:
# - SNS topic for alert delivery
# - optional email subscription
# - CloudWatch dashboard
# - CloudWatch alarms created from generic HCL definitions
#
# Dashboards remain architecture-specific and are expected to be rendered by
# the consuming blueprint, typically from a JSON template file.
# ============================================================================

# ============================================================================
# DATA SOURCES
# ============================================================================

data "aws_region" "current" {}

# ============================================================================
# SNS TOPIC FOR ALERTS
# ============================================================================

resource "aws_sns_topic" "alerts" {
  name              = coalesce(var.sns_topic_name_override, "${local.name_prefix}-alerts")
  display_name      = "${var.app_id} ${var.environment} Alerts"
  kms_master_key_id = var.sns_kms_key_id

  tags = merge(
    var.tags,
    {
      Name        = coalesce(var.sns_topic_name_override, "${local.name_prefix}-alerts")
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ============================================================================
# EMAIL SUBSCRIPTION
# ============================================================================

resource "aws_sns_topic_subscription" "email_alerts" {
  count = local.email_configured ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email

  # Email subscriptions remain opt-in at runtime because AWS requires manual
  # confirmation for each recipient.
}

# ============================================================================
# CLOUDWATCH DASHBOARD
# ============================================================================

resource "aws_cloudwatch_dashboard" "main" {
  count = var.create_dashboard ? 1 : 0

  dashboard_name = coalesce(var.dashboard_name_override, "${local.dashboard_prefix}-dashboard")
  dashboard_body = var.dashboard_body

  lifecycle {
    precondition {
      condition     = var.dashboard_body != null && can(jsondecode(var.dashboard_body))
      error_message = "dashboard_body must contain valid JSON when create_dashboard is true."
    }
  }
}

# ============================================================================
# CLOUDWATCH ALARMS
# ============================================================================
# Alarm definitions are intentionally provided by the consumer so the module
# can support any architecture without encoding blueprint-specific metrics.
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.enable_alarms ? local.normalized_alarm_definitions : {}

  alarm_name = coalesce(
    try(each.value.alarm_name, null),
    "${local.name_prefix}-${replace(each.key, "_", "-")}"
  )

  alarm_description   = try(each.value.alarm_description, null)
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold
  datapoints_to_alarm = try(each.value.datapoints_to_alarm, null)
  treat_missing_data  = try(each.value.treat_missing_data, "notBreaching")
  actions_enabled     = try(each.value.actions_enabled, true)

  # If the consumer does not explicitly define alarm actions, route state
  # changes through the shared SNS topic by default.
  alarm_actions = try(each.value.alarm_actions, null) != null ? each.value.alarm_actions : [
    aws_sns_topic.alerts.arn
  ]

  ok_actions = try(each.value.ok_actions, null) != null ? each.value.ok_actions : [
    aws_sns_topic.alerts.arn
  ]

  insufficient_data_actions = try(each.value.insufficient_data_actions, [])

  # Standard metric fields are only populated for simple alarms.
  metric_name        = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.metric_name, null) : null
  namespace          = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.namespace, null) : null
  period             = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.period, null) : null
  statistic          = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.statistic, null) : null
  extended_statistic = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.extended_statistic, null) : null
  unit               = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.unit, null) : null
  dimensions         = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.dimensions, null) : null

  dynamic "metric_query" {
    for_each = try(each.value.metric_queries, [])

    content {
      id          = metric_query.value.id
      expression  = try(metric_query.value.expression, null)
      label       = try(metric_query.value.label, null)
      return_data = try(metric_query.value.return_data, null)
      account_id  = try(metric_query.value.account_id, null)

      dynamic "metric" {
        for_each = try(metric_query.value.metric, null) == null ? [] : [metric_query.value.metric]

        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = try(metric.value.unit, null)
          dimensions  = try(metric.value.dimensions, null)
        }
      }
    }
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {})
  )
}
