# ============================================================================
# ECS MODULE - service.tf (Task Definition and ECS Service)
# ============================================================================
# Creates the ECS task definition and ECS service.
# ============================================================================

# ============================================================================
# TASK DEFINITION
# ============================================================================

resource "aws_ecs_task_definition" "this" {
  family = "${local.service_name}-app"

  # Fargate configuration.
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # Compute resources.
  cpu    = var.task_cpu
  memory = var.task_memory

  # IAM roles.
  execution_role_arn = aws_iam_role.task_execution.arn
  task_role_arn      = aws_iam_role.task.arn

  # Container definition.
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      # Port mappings.
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      # Environment variables (non-sensitive).
      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = tostring(value)
        }
      ]

      # Secrets from Secrets Manager or SSM Parameter Store.
      secrets = [
        for key, arn in var.secrets : {
          name      = key
          valueFrom = arn
        }
      ]

      # CloudWatch Logs configuration.
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      # Optional container health check.
      healthCheck = var.container_health_check

      linuxParameters = {
        initProcessEnabled = true
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      Name        = "${local.service_name}-task-definition"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# ============================================================================
# ECS SERVICE
# ============================================================================

resource "aws_ecs_service" "this" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn

  # Desired state.
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  launch_type = "FARGATE"

  # Network configuration.
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  # Optional load balancer integration.
  dynamic "load_balancer" {
    for_each = var.alb_target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.alb_target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  # Deployment circuit breaker for failed rollouts.
  deployment_circuit_breaker {
    enable   = var.enable_circuit_breaker
    rollback = var.enable_circuit_breaker_rollback
  }

  # Optional ECS Exec support for operational debugging.
  enable_execute_command = var.enable_execute_command

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(
    var.tags,
    {
      Name        = local.service_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
