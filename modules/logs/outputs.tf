# ============================================================================
# LOGS MODULE OUTPUTS - outputs.tf
# ============================================================================
# These outputs expose the bucket identifiers needed by the CloudFront module
# and any operational tooling that needs to inspect log storage.
# ============================================================================

output "bucket_id" {
  description = "ID of the logs bucket"
  value       = aws_s3_bucket.logs.id
}

output "bucket_domain_name" {
  description = "Domain name of the logs bucket"
  value       = aws_s3_bucket.logs.bucket_domain_name
  # This is the value typically passed to CloudFront logging configuration.
}
