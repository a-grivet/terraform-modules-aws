# ============================================================================
# ECR (ELASTIC CONTAINER REGISTRY) MODULE - main.tf
# ============================================================================
# This module creates and manages an Amazon ECR repository for storing Docker
# container images used by ECS tasks or other container runtimes.
#
# What this module does:
# - creates a private ECR repository for Docker images
# - configures image scanning for security vulnerabilities
# - sets up lifecycle policies to automatically clean up old images
# - enables encryption at rest using KMS or AWS-managed keys
# - optionally configures a repository policy for custom access patterns
# ============================================================================

# ============================================================================
# DATA SOURCES - Retrieve AWS Region Information
# ============================================================================

data "aws_region" "current" {}
# Used for example Docker login and push commands.

# ============================================================================
# ECR REPOSITORY - Container Image Storage
# ============================================================================

resource "aws_ecr_repository" "this" {
  # Repository name format: {project}-{environment}
  # Example: myapp-dev, myapp-prod
  name = local.name

  # Image tag mutability controls whether an existing tag can be overwritten.
  image_tag_mutability = var.image_tag_mutability
  force_delete         = true

  # Automatically scan images for known vulnerabilities after push.
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # Encrypt images at rest with either AWS-managed keys or a customer-managed
  # KMS key.
  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  tags = merge(
    var.tags,
    {
      Name      = local.name
      Component = "ContainerRegistry"
    }
  )
}

# ============================================================================
# ECR LIFECYCLE POLICY - Automatic Image Cleanup
# ============================================================================
# Lifecycle rules keep the repository tidy and reduce storage costs by
# retaining only the images that still matter operationally.

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.lifecycle_policy_max_image_count} tagged images"

        selection = merge(
          {
            tagStatus   = "tagged"
            countType   = "imageCountMoreThan"
            countNumber = var.lifecycle_policy_max_image_count
          },
          length(var.lifecycle_policy_tag_prefix_list) > 0 ? {
            tagPrefixList = var.lifecycle_policy_tag_prefix_list
          } : {}
        )

        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Expire untagged images older than ${var.lifecycle_policy_untagged_days} days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.lifecycle_policy_untagged_days
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ============================================================================
# ECR REPOSITORY POLICY - Access Control (Optional)
# ============================================================================
# By default, only the owning account can access the repository. This policy is
# created only when custom JSON is supplied, for example for cross-account pull
# access.

resource "aws_ecr_repository_policy" "this" {
  count = var.repository_policy_json != null ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy_json
}
