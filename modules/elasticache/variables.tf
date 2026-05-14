# ============================================================================
# ELASTICACHE REDIS MODULE - variables.tf
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

# ===== NETWORK =====

variable "subnet_ids" {
  description = "List of subnet IDs for Redis (private subnets)"
  type        = list(string)
}

variable "redis_security_group_id" {
  description = "Security group ID for Redis (from security-groups module)"
  type        = string
}

# ===== REDIS CONFIGURATION =====

variable "redis_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "ElastiCache node type for Redis nodes"
  type        = string
}

variable "num_cache_nodes" {
  description = "Number of cache nodes (1 = no replica, 2+ = HA with replicas)"
  type        = number
}

variable "parameter_group_family" {
  description = "Redis parameter group family (must match redis_version)"
  type        = string
  default     = "redis7"
}

variable "port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

# ===== HIGH AVAILABILITY =====

variable "automatic_failover_enabled" {
  description = "Enable automatic failover (requires num_cache_nodes >= 2)"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ deployment (requires automatic_failover_enabled = true)"
  type        = bool
  default     = false
}

# ===== BACKUP & MAINTENANCE =====

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots (0 = disabled)"
  type        = number
  default     = 1
}

variable "snapshot_window" {
  description = "Daily backup window in UTC (for example 03:00-05:00)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly maintenance window in UTC"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

# ===== SECURITY =====

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit (TLS)"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "Auth token for Redis (required if transit_encryption_enabled is true)"
  type        = string
  sensitive   = true
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest"
  type        = string
  default     = null
}

# ===== MONITORING =====

variable "notification_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
  default     = null
}

# ===== PARAMETER GROUP =====

variable "maxmemory_policy" {
  description = "Eviction policy when memory is full"
  type        = string
  default     = "allkeys-lru"
}

variable "timeout" {
  description = "Close connection after client is idle for N seconds (0 = disabled)"
  type        = number
  default     = 300
}
