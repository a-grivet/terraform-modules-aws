# ============================================================================
# SECRETS MANAGER MODULE OUTPUTS - outputs.tf
# ============================================================================
# This file defines output values for the Secrets Manager module.
#
# SECURITY NOTE:
# Sensitive outputs are hidden from logs but stored in Terraform state.
# Always encrypt your state file (S3 backend with encryption).
# ============================================================================

# ============================================================================
# SECRET METADATA OUTPUTS
# ============================================================================

output "secret_id" {
  description = "ID of the secret"
  value       = aws_secretsmanager_secret.this.id
  # Use for: GetSecretValue API calls, automation scripts
}

output "secret_arn" {
  description = "ARN of the secret"
  value       = aws_secretsmanager_secret.this.arn
  # Use for: IAM policies, Lambda environment variables
  # Example: "arn:aws:secretsmanager:region:account:secret:name-AbCdEf"
}

output "secret_name" {
  description = "Name of the secret"
  value       = aws_secretsmanager_secret.this.name
  # Use for: Application code, AWS CLI commands
}

output "secret_version_id" {
  description = "Version ID of the secret"
  value       = aws_secretsmanager_secret_version.this.version_id
  # Use for: Audit logging, rollback operations
}

# ============================================================================
# PASSWORD OUTPUTS (SENSITIVE)
# ============================================================================

output "secret_value" {
  description = "The secret value (password)"
  value       = aws_secretsmanager_secret_version.this.secret_string
  sensitive   = true
  # Contains the actual password or secret data
  # Hidden from Terraform logs
}

output "random_password" {
  description = "The generated random password (if create_random_password is true)"
  value       = var.create_random_password ? random_password.master_password[0].result : null
  sensitive   = true
  # Only set when create_random_password = true
}
