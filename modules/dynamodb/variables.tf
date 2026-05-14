# ============================================================================
# DYNAMODB MODULE - variables.tf
# ============================================================================

# ===== GENERAL =====

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
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# ===== TABLE CONFIGURATION =====

variable "tables" {
  description = "Map of DynamoDB tables to create"
  type = map(object({
    billing_mode   = optional(string, "PAY_PER_REQUEST")
    read_capacity  = optional(number, 5)
    write_capacity = optional(number, 5)

    hash_key      = string
    hash_key_type = optional(string, "S")

    range_key      = optional(string, null)
    range_key_type = optional(string, "S")

    # Time-To-Live.
    ttl_enabled        = optional(bool, false)
    ttl_attribute_name = optional(string, "ttl")

    # Point-in-time recovery.
    point_in_time_recovery = optional(bool, true)

    # Streams for event sourcing or triggers.
    stream_enabled   = optional(bool, false)
    stream_view_type = optional(string, "NEW_AND_OLD_IMAGES")

    # Global secondary indexes.
    global_secondary_indexes = optional(list(object({
      name               = string
      hash_key           = string
      hash_key_type      = optional(string, "S")
      range_key          = optional(string, null)
      range_key_type     = optional(string, "S")
      projection_type    = optional(string, "ALL")
      non_key_attributes = optional(list(string), [])
      read_capacity      = optional(number, 5)
      write_capacity     = optional(number, 5)
    })), [])

    # Local secondary indexes.
    local_secondary_indexes = optional(list(object({
      name               = string
      range_key          = string
      range_key_type     = optional(string, "S")
      projection_type    = optional(string, "ALL")
      non_key_attributes = optional(list(string), [])
    })), [])
  }))

  default = {}
}

# ===== ENCRYPTION =====

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest (if not provided, AWS managed key is used)"
  type        = string
  default     = null
}

# ===== AUTO-SCALING (only for PROVISIONED mode) =====

variable "enable_autoscaling" {
  description = "Enable auto-scaling for PROVISIONED tables"
  type        = bool
  default     = false
}

variable "autoscaling_read_target" {
  description = "Target utilization percentage for read capacity (1-100)"
  type        = number
  default     = 70
}

variable "autoscaling_write_target" {
  description = "Target utilization percentage for write capacity (1-100)"
  type        = number
  default     = 70
}

variable "autoscaling_read_min" {
  description = "Minimum read capacity for auto-scaling"
  type        = number
  default     = 5
}

variable "autoscaling_read_max" {
  description = "Maximum read capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_min" {
  description = "Minimum write capacity for auto-scaling"
  type        = number
  default     = 5
}

variable "autoscaling_write_max" {
  description = "Maximum write capacity for auto-scaling"
  type        = number
  default     = 100
}
