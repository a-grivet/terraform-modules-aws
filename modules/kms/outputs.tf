# ============================================================================
# KMS MODULE OUTPUTS - outputs.tf
# ============================================================================
# This file defines output values for the KMS key and alias.
# Outputs provide identifiers needed by other modules to use the key for
# encryption in AWS services (EBS, RDS, S3, Secrets Manager, etc.).
# ============================================================================

# ============================================================================
# KMS KEY OUTPUTS
# ============================================================================

output "key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.this.key_id
  # KMS Key ID: Unique identifier in UUID format
  # Example: "a1b2c3d4-5e6f-7g8h-9i0j-k1l2m3n4o5p6"
  # Used for: KMS API calls, CloudTrail log analysis
}

output "key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.this.arn
  # KMS Key ARN: Full Amazon Resource Name
  # Example: "arn:aws:kms:eu-west-1:123456789012:key/a1b2c3d4-..."
}

output "key_alias_name" {
  description = "Alias name of the KMS key"
  value       = aws_kms_alias.this.name
  # KMS Key Alias: Human-friendly identifier
  # Example: "alias/myapp-prod-ebs"
}

output "key_alias_arn" {
  description = "ARN of the KMS key alias"
  value       = aws_kms_alias.this.arn
  # KMS Key Alias ARN
  # Can be used instead of key_arn for encryption configuration
  # Functionally identical to key_arn
}
