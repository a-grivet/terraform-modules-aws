# ============================================================================
# MONITORING MODULE - locals.tf
# ============================================================================
# Centralizes naming logic following the organization naming convention.
# Pattern : <prefix>-[np]-<app_id>-<env>-[label]
# Reference: https://
#
# Two prefixes are defined:
#   sns-  for the SNS topic and CloudWatch alarms (alert delivery resources)
#   cw-   for the CloudWatch dashboard (observability resource)
# ============================================================================

locals {
  np_segment       = var.environment == "p" ? "" : "np-"
  base             = "${local.np_segment}${var.app_id}-${var.environment}"
  label_suffix     = var.label != null ? "-${var.label}" : ""
  name_prefix      = "sns-${local.base}${local.label_suffix}"
  dashboard_prefix = "cw-${local.base}${local.label_suffix}"

  email_configured = trimspace(var.alert_email) != ""

  # Alarm keys are normalized so downstream outputs remain predictable even
  # when consumers use mixed-case identifiers in their local definitions.
  normalized_alarm_definitions = {
    for alarm_key, alarm in var.alarm_definitions :
    lower(alarm_key) => alarm
  }
}
