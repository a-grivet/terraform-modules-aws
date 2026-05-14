# ============================================================================
# ECS MODULE - cluster.tf (ECS Cluster and CloudWatch Logs)
# ============================================================================
# Creates the ECS cluster and centralized logging for all tasks.
# ============================================================================

# ============================================================================
# ECS CLUSTER
# ============================================================================

resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  # Container Insights provides CloudWatch monitoring for containers.
  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name        = local.cluster_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# ============================================================================
# ECS CLUSTER CAPACITY PROVIDERS
# ============================================================================
# Defines the infrastructure backing task placement: Fargate or Fargate Spot.

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }
}

# ============================================================================
# CLOUDWATCH LOG GROUP
# ============================================================================
# Central log group shared by containers running in this ECS environment.

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.cluster_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.cloudwatch_kms_key_id

  tags = merge(
    var.tags,
    {
      Name        = "${local.cluster_name}-logs"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
