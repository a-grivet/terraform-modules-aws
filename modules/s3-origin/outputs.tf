output "bucket_id" {
  description = "ID of the S3 origin bucket"
  value       = aws_s3_bucket.origin.id
}

output "bucket_arn" {
  description = "ARN of the S3 origin bucket"
  value       = aws_s3_bucket.origin.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.origin.bucket_regional_domain_name
}
