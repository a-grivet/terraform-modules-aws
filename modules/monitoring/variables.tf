# ============================================================================
# MONITORING MODULE VARIABLES - variables.tf
# ============================================================================
# This module is intentionally generic. Consumers provide:
# - dashboard JSON rendered from their own template
# - alarm definitions expressed in HCL maps
#
# This keeps the shared module reusable while allowing each blueprint to own
# the metrics that matter for its architecture.
# ============================================================================

# ============================================================================
# GENERAL CONFIGURATION
# ============================================================================

variable "app_id" {
  # 3rd segment of the organization naming convention: <prefix>-[np]-<app_id>-<env>-[label]
  description = "Application identifier (AppId) as registered in the your application catalog."
  type        = string
}

variable "environment" {
  # 4th segment of the organization naming convention. Drives the np segment automatically.
  description = "Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod)."
  type        = string

  validation {
    condition     = contains(["c", "t", "d", "s", "p"], var.environment)
    error_message = "environment must be one of: c (poc), t (test/sandbox), d (dev), s (stage), p (prod)."
  }
}

variable "label" {
  # Optional 5th segment of the organization naming convention.
  description = "Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a')."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to all monitoring resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# SNS CONFIGURATION
# ============================================================================

variable "alert_email" {
  description = "Email address to receive alarm notifications"
  type        = string
  default     = ""
}

variable "sns_kms_key_id" {
  description = "KMS key ID used to encrypt the SNS topic (optional)"
  type        = string
  default     = null
  nullable    = true
}

variable "sns_topic_name_override" {
  description = "Optional custom SNS topic name. When unset, the standard project-environment name is used"
  type        = string
  default     = null
  nullable    = true
}

# ============================================================================
# DASHBOARD CONFIGURATION
# ============================================================================

variable "create_dashboard" {
  description = "Create a CloudWatch dashboard from dashboard_body"
  type        = bool
  default     = true
}

variable "dashboard_name_override" {
  description = "Optional custom dashboard name. When unset, the standard project-environment name is used"
  type        = string
  default     = null
  nullable    = true
}

variable "dashboard_body" {
  description = "Rendered CloudWatch dashboard JSON body. Typically produced by templatefile() from the consuming blueprint"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.dashboard_body == null || can(jsondecode(var.dashboard_body))
    error_message = "dashboard_body must be valid JSON."
  }
}

# ============================================================================
# ALARM CONFIGURATION
# ============================================================================

variable "enable_alarms" {
  description = "Enable CloudWatch alarm creation"
  type        = bool
  default     = true
}

variable "alarm_definitions" {
  description = "Map of CloudWatch alarm definitions. Keys are normalized to lower-case inside the module for stable outputs"
  type = map(object({
    alarm_name                = optional(string)
    alarm_description         = optional(string)
    comparison_operator       = string
    evaluation_periods        = number
    threshold                 = number
    datapoints_to_alarm       = optional(number)
    treat_missing_data        = optional(string)
    actions_enabled           = optional(bool)
    alarm_actions             = optional(list(string))
    ok_actions                = optional(list(string))
    insufficient_data_actions = optional(list(string))
    metric_name               = optional(string)
    namespace                 = optional(string)
    period                    = optional(number)
    statistic                 = optional(string)
    extended_statistic        = optional(string)
    unit                      = optional(string)
    dimensions                = optional(map(string))
    tags                      = optional(map(string))
    metric_queries = optional(list(object({
      id          = string
      expression  = optional(string)
      label       = optional(string)
      return_data = optional(bool)
      account_id  = optional(string)
      metric = optional(object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string
        unit        = optional(string)
        dimensions  = optional(map(string))
      }))
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, alarm in var.alarm_definitions :
      (
        length(try(alarm.metric_queries, [])) > 0 ||
        (
          try(alarm.metric_name, null) != null &&
          try(alarm.namespace, null) != null &&
          try(alarm.period, null) != null &&
          (
            try(alarm.statistic, null) != null ||
            try(alarm.extended_statistic, null) != null
          )
        )
      )
    ])
    error_message = "Each alarm must define either metric_queries or the standard metric fields metric_name, namespace, period, and statistic/extended_statistic."
  }

  validation {
    condition = alltrue([
      for _, alarm in var.alarm_definitions :
      !(
        try(alarm.statistic, null) != null &&
        try(alarm.extended_statistic, null) != null
      )
    ])
    error_message = "Each alarm can use either statistic or extended_statistic, but not both."
  }
}
