# ============================================================================
# SECURITY GROUPS MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the Security Groups module.
# The goal is to keep the contract simple for common 3-tier architectures while
# still supporting optional bastion and Redis-specific patterns.
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

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]{17}$", var.vpc_id))
    error_message = "VPC ID must be in format: vpc-xxxxxxxxxxxxxxxxx"
  }
}

# ============================================================================
# APPLICATION CONFIGURATION
# ============================================================================

variable "app_port" {
  description = "Application port where backend services listen"
  type        = number
  default     = 80

  validation {
    condition     = var.app_port > 0 && var.app_port <= 65535
    error_message = "Application port must be between 1 and 65535."
  }
  # Common values:
  # - 80: HTTP
  # - 8080: Tomcat / alternate web apps
  # - 3000: Node.js
  # - 8000: Python application servers
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306

  validation {
    condition     = var.db_port > 0 && var.db_port <= 65535
    error_message = "Database port must be between 1 and 65535."
  }
  # Common values:
  # - 3306: MySQL / Aurora MySQL
  # - 5432: PostgreSQL / Aurora PostgreSQL
}

variable "enable_redis" {
  description = "Whether to create a dedicated Redis security group"
  type        = bool
  default     = false
  # Enable this for architectures with ElastiCache or another Redis-compatible
  # cache tier that should only be reachable from the app tier.
}

variable "redis_port" {
  description = "Redis port"
  type        = number
  default     = 6379

  validation {
    condition     = var.redis_port > 0 && var.redis_port <= 65535
    error_message = "Redis port must be between 1 and 65535."
  }
  # 6379 is the default Redis port in most deployments.
}

# ============================================================================
# NETWORK ACCESS CONFIGURATION
# ============================================================================

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  # Restrict to specific IPs for tighter security:
  # ["1.2.3.4/32", "5.6.7.8/32"]
}

variable "enable_https" {
  description = "Enable HTTPS ingress on the ALB security group"
  type        = bool
  default     = true
}

# ============================================================================
# OPTIONAL BASTION ACCESS
# ============================================================================

variable "enable_ssh_bastion" {
  description = "Enable SSH access from bastion to app tier"
  type        = bool
  default     = false
  # Mainly useful for EC2-based application tiers. It is harmless to keep this
  # disabled in container/serverless-oriented topologies.
}

variable "enable_db_bastion_access" {
  description = "Enable database access from bastion for troubleshooting"
  type        = bool
  default     = false
}

variable "bastion_security_group_id" {
  description = "Security group ID of bastion host (required if bastion access is enabled)"
  type        = string
  default     = ""

  validation {
    condition     = var.bastion_security_group_id == "" || can(regex("^sg-[a-z0-9]{17}$", var.bastion_security_group_id))
    error_message = "Bastion security group ID must be empty or in format: sg-xxxxxxxxxxxxxxxxx"
  }
}

# ============================================================================
# TAGS
# ============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  # Tags help with cost allocation, ownership, filtering, and automation.
}
