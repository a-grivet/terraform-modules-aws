# ============================================================================
# SSM PARAMETERS MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the SSM Parameters module.
# ============================================================================

# ============================================================================
# NAMING AND TAGGING
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

variable "parameter_path_prefix" {
  description = "Custom parameter path prefix (optional, overrides default)"
  type        = string
  default     = null
  # Default: /{project_name}/{environment}/database
  # Custom: /custom/path/to/db
}

variable "tags" {
  description = "Tags to apply to all SSM parameters"
  type        = map(string)
  default     = {}
}

# ============================================================================
# ENCRYPTION
# ============================================================================

variable "kms_key_id" {
  description = "KMS key ID for encrypting SecureString parameters"
  type        = string
  # Get from KMS module: module.kms_ssm.key_id
}

# ============================================================================
# DATABASE CONFIGURATION VALUES
# ============================================================================

variable "db_writer_endpoint" {
  description = "Aurora cluster writer endpoint"
  type        = string
  # Get from Aurora module: module.aurora.cluster_endpoint
  # Format: cluster-name.cluster-abc123.region.rds.amazonaws.com
}

variable "db_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  type        = string
  # Get from Aurora module: module.aurora.cluster_reader_endpoint
  # Format: cluster-name.cluster-ro-abc123.region.rds.amazonaws.com
}

variable "db_port" {
  description = "Database port number"
  type        = number
  # Get from Aurora module: module.aurora.cluster_port
  # Common: 3306 (MySQL), 5432 (PostgreSQL)
}

variable "db_name" {
  description = "Database name"
  type        = string
  # Get from Aurora module: module.aurora.cluster_database_name
  # The database/schema name to connect to
}

variable "db_username" {
  description = "Database master username"
  type        = string
  # Get from Aurora module: module.aurora.cluster_master_username
}

variable "db_secret_arn" {
  description = "ARN of Secrets Manager secret containing database password"
  type        = string
  # Get from Secrets Manager module: module.db_secret.secret_arn
  # Applications use this ARN to retrieve password
}
