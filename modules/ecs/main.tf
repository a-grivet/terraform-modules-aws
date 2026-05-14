# ============================================================================
# ECS MODULE - main.tf (Orchestration)
# ============================================================================
# This module creates a complete ECS Fargate environment:
# - IAM roles (Task Execution + Task)
# - ECS Cluster
# - CloudWatch Log Group
# - ECS Task Definition
# - ECS Service
#
# Everything needed to run containerized applications on ECS Fargate.
#
# Architecture:
# ALB -> ECS Service -> Tasks (Fargate) -> Container (ECR image)
#                         |
#                         -> CloudWatch Logs
#
# IAM roles:
# - Task Execution Role: used by ECS agent (pull ECR, push logs, get secrets)
# - Task Role: used by application code (access AWS services)
# ============================================================================

# Data sources for AWS account and region.
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# SUBMODULE CALLS
# ============================================================================
# The actual resources are defined in separate files for clarity:
# - iam.tf: IAM roles and policies
# - cluster.tf: ECS cluster and CloudWatch log group
# - service.tf: Task definition and ECS service
# ============================================================================
