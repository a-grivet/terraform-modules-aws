# ============================================================================
# ECR MODULE - outputs.tf
# ============================================================================
# Useful repository identifiers and example values consumed by ECS and CI/CD.
# ============================================================================

output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "Full ARN of the ECR repository"
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "URL of the ECR repository used for docker push and pull commands"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_registry_id" {
  description = "Registry ID (AWS account ID) where the repository exists"
  value       = aws_ecr_repository.this.registry_id
}

output "lifecycle_policy_text" {
  description = "The lifecycle policy document applied to the repository"
  value       = aws_ecr_lifecycle_policy.this.policy
}

output "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  value       = aws_ecr_repository.this.image_tag_mutability
}

output "image_scanning_enabled" {
  description = "Whether image scanning on push is enabled"
  value       = aws_ecr_repository.this.image_scanning_configuration[0].scan_on_push
}

output "encryption_type" {
  description = "Encryption type used for images at rest (AES256 or KMS)"
  value       = aws_ecr_repository.this.encryption_configuration[0].encryption_type
}

output "kms_key" {
  description = "KMS key ARN used for encryption, or null if using AES256"
  value       = aws_ecr_repository.this.encryption_configuration[0].kms_key
}

output "docker_login_command" {
  description = "AWS CLI command to authenticate Docker to this ECR registry"
  value       = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.this.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

output "example_docker_push_command" {
  description = "Example docker push command for this repository"
  value       = "docker push ${aws_ecr_repository.this.repository_url}:latest"
}

output "example_ecs_image_uri" {
  description = "Example image URI to use in ECS task definitions"
  value       = "${aws_ecr_repository.this.repository_url}:latest"
}

output "cloudwatch_log_group_name" {
  description = "Standard CloudWatch Log Group name for ECR repository events"
  value       = "/aws/ecr/repository/${aws_ecr_repository.this.name}"
}
