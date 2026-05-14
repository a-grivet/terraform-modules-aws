# ============================================================================
# ECS MODULE - iam.tf (IAM Roles)
# ============================================================================
# Creates IAM roles for ECS Fargate tasks.
#
# Two roles are required:
# 1. Task Execution Role: used by ECS agent and platform integrations
# 2. Task Role: used by the application code running inside the container
# ============================================================================

# ============================================================================
# TASK EXECUTION ROLE - ECS Agent Permissions
# ============================================================================

resource "aws_iam_role" "task_execution" {
  name_prefix = local.iam_exec_prefix
  path        = "/service-role/"
  description = "ECS Task Execution Role for ${local.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    var.tags,
    {
      Name        = "${local.iam_exec_prefix}role"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# Basic ECS task execution permissions: pull ECR images and write CloudWatch logs.
resource "aws_iam_role_policy_attachment" "task_execution_default" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional access to Secrets Manager, SSM Parameter Store, and KMS decryption.
resource "aws_iam_role_policy" "task_execution_secrets" {
  count = var.enable_secrets_access ? 1 : 0

  name = "secrets-access"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_manager_arns
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.app_id}/${var.environment}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arns
      }
    ]
  })
}

# ============================================================================
# TASK ROLE - Application Permissions
# ============================================================================

resource "aws_iam_role" "task" {
  name_prefix = local.iam_task_prefix
  path        = "/service-role/"
  description = "ECS Task Role for ${local.cluster_name} application"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    var.tags,
    {
      Name        = "${local.iam_task_prefix}role"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# Application-specific inline policies.
resource "aws_iam_role_policy" "task_custom" {
  for_each = var.task_custom_policies

  name   = each.key
  role   = aws_iam_role.task.id
  policy = each.value
}

# Optional AWS-managed policies attached to the task role.
resource "aws_iam_role_policy_attachment" "task_managed" {
  for_each = toset(var.task_managed_policy_arns)

  role       = aws_iam_role.task.name
  policy_arn = each.value
}
