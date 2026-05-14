# ============================================================================
# SSM PARAMETER STORE MODULE - main.tf
# ============================================================================
# This module creates AWS Systems Manager Parameter Store entries for database
# configuration. Stores database connection metadata (endpoints, ports, etc.)
# while passwords are kept in Secrets Manager.
#
# What this module does:
# - Stores database endpoints (writer/reader)
# - Stores database metadata (port, name, username)
# - Stores reference to Secrets Manager password (ARN pointer)
# - All parameters encrypted with KMS
#
# Pattern: Database password in Secrets Manager, connection details here
# ============================================================================

# ============================================================================
# LOCAL VARIABLES
# ============================================================================

# ============================================================================
# DATABASE WRITER ENDPOINT
# ============================================================================

resource "aws_ssm_parameter" "db_writer_endpoint" {
  name        = "${local.path_prefix}/writer-endpoint"
  description = "Aurora cluster writer endpoint for read/write operations"
  type        = "SecureString" # Encrypted with KMS
  value       = var.db_writer_endpoint
  key_id      = var.kms_key_id

  # Writer endpoint: Primary instance for INSERT/UPDATE/DELETE operations

  tags = merge(
    local.common_tags,
    {
      Name        = "db-writer-endpoint"
      Description = "Database writer endpoint"
    }
  )
}

# ============================================================================
# DATABASE READER ENDPOINT
# ============================================================================

resource "aws_ssm_parameter" "db_reader_endpoint" {
  name        = "${local.path_prefix}/reader-endpoint"
  description = "Aurora cluster reader endpoint for read-only operations"
  type        = "SecureString"
  value       = var.db_reader_endpoint
  key_id      = var.kms_key_id

  # Reader endpoint: Read replicas for SELECT queries (load balancing)

  tags = merge(
    local.common_tags,
    {
      Name        = "db-reader-endpoint"
      Description = "Database reader endpoint"
    }
  )
}

# ============================================================================
# DATABASE PORT
# ============================================================================

resource "aws_ssm_parameter" "db_port" {
  name        = "${local.path_prefix}/port"
  description = "Database port number"
  type        = "String" # Not sensitive, no encryption needed
  value       = tostring(var.db_port)

  # Common ports: 3306 (MySQL), 5432 (PostgreSQL)

  tags = merge(
    local.common_tags,
    {
      Name        = "db-port"
      Description = "Database port"
    }
  )
}

# ============================================================================
# DATABASE NAME
# ============================================================================

resource "aws_ssm_parameter" "db_name" {
  name        = "${local.path_prefix}/name"
  description = "Database name"
  type        = "String"
  value       = var.db_name

  # The database name (schema) to connect to

  tags = merge(
    local.common_tags,
    {
      Name        = "db-name"
      Description = "Database name"
    }
  )
}

# ============================================================================
# DATABASE USERNAME
# ============================================================================

resource "aws_ssm_parameter" "db_username" {
  name        = "${local.path_prefix}/username"
  description = "Database username"
  type        = "String"
  value       = var.db_username

  tags = merge(
    local.common_tags,
    {
      Name        = "db-username"
      Description = "Database username"
    }
  )
}

# ============================================================================
# SECRETS MANAGER ARN REFERENCE
# ============================================================================

resource "aws_ssm_parameter" "db_secret_arn" {
  name        = "${local.path_prefix}/secret-arn"
  description = "ARN of Secrets Manager secret containing database password"
  type        = "String"
  value       = var.db_secret_arn

  # Stores pointer to Secrets Manager secret (not the password itself)
  # Applications use this ARN to retrieve password from Secrets Manager

  tags = merge(
    local.common_tags,
    {
      Name        = "db-secret-arn"
      Description = "Secrets Manager ARN"
    }
  )
}
