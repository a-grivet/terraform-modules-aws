# ============================================================================
# SSM PARAMETERS MODULE OUTPUTS - outputs.tf
# ============================================================================
# This file defines output values for the SSM Parameters module.
# Outputs provide parameter names and ARNs for application configuration.
# ============================================================================

# ============================================================================
# PARAMETER NAMES (PATHS)
# ============================================================================

output "parameter_names" {
  description = "Map of all SSM parameter names (paths)"
  value = {
    writer_endpoint = aws_ssm_parameter.db_writer_endpoint.name
    reader_endpoint = aws_ssm_parameter.db_reader_endpoint.name
    port            = aws_ssm_parameter.db_port.name
    database_name   = aws_ssm_parameter.db_name.name
    username        = aws_ssm_parameter.db_username.name
    secret_arn      = aws_ssm_parameter.db_secret_arn.name
  }
  # Applications use these paths to retrieve parameter values
  # Example: "/myapp/prod/database/writer-endpoint"
}

# ============================================================================
# PARAMETER ARNS
# ============================================================================

output "parameter_arns" {
  description = "Map of all SSM parameter ARNs (for IAM policies)"
  value = {
    writer_endpoint = aws_ssm_parameter.db_writer_endpoint.arn
    reader_endpoint = aws_ssm_parameter.db_reader_endpoint.arn
    port            = aws_ssm_parameter.db_port.arn
    database_name   = aws_ssm_parameter.db_name.arn
    username        = aws_ssm_parameter.db_username.arn
    secret_arn      = aws_ssm_parameter.db_secret_arn.arn
  }
  # Use in IAM policies to grant parameter access
}

# ============================================================================
# INDIVIDUAL PARAMETER OUTPUTS
# ============================================================================

output "writer_endpoint_parameter_name" {
  description = "Writer endpoint parameter name"
  value       = aws_ssm_parameter.db_writer_endpoint.name
}

output "reader_endpoint_parameter_name" {
  description = "Reader endpoint parameter name"
  value       = aws_ssm_parameter.db_reader_endpoint.name
}

output "port_parameter_name" {
  description = "Port parameter name"
  value       = aws_ssm_parameter.db_port.name
}

output "database_name_parameter_name" {
  description = "Database name parameter name"
  value       = aws_ssm_parameter.db_name.name
}

output "username_parameter_name" {
  description = "Username parameter name"
  value       = aws_ssm_parameter.db_username.name
}

output "secret_arn_parameter_name" {
  description = "Secret ARN parameter name"
  value       = aws_ssm_parameter.db_secret_arn.name
}

# ============================================================================
# CONVENIENCE OUTPUTS
# ============================================================================

output "parameter_path_prefix" {
  description = "Parameter path prefix used for all parameters"
  value       = local.path_prefix
  # Useful for bulk parameter retrieval or IAM path-based policies
  # Example: "/myapp/prod/database"
}

output "path_prefix" {
  description = "Parameter path prefix (alias for parameter_path_prefix)"
  value       = local.path_prefix
  # Backward compatibility alias
}
