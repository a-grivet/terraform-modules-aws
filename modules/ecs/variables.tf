# ============================================================================
# ECS MODULE - variables.tf (All Variables)
# ============================================================================

# ============================================================================
# GENERAL
# ============================================================================

variable "app_id" {
  # 3rd segment of the organization naming convention: <prefix>-[np]-<app_id>-<env>-[label]
  description = "Application identifier (AppId) as registered in the your application catalog."
  type        = string
}

variable "environment" {
  # 4th segment of the organization naming convention. Drives the np segment automatically.
  description = "Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod)."
  type        = string

  validation {
    condition     = contains(["c", "t", "d", "s", "p"], var.environment)
    error_message = "environment must be one of: c (poc), t (test/sandbox), d (dev), s (stage), p (prod)."
  }
}

variable "label" {
  # Optional 5th segment of the organization naming convention.
  description = "Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a')."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# IAM CONFIGURATION
# ============================================================================

variable "permissions_boundary_arn" {
  description = "ARN of the permissions boundary policy"
  type        = string
  default     = null
}

variable "enable_secrets_access" {
  description = "Enable Secrets Manager and SSM Parameter Store access for task execution role"
  type        = bool
  default     = true
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager secret ARNs that task execution role can access"
  type        = list(string)
  default     = ["*"]
}

variable "kms_key_arns" {
  description = "List of KMS key ARNs for decrypting secrets"
  type        = list(string)
  default     = ["*"]
}

variable "task_custom_policies" {
  description = "Map of custom IAM policies for task role (policy_name => policy_json)"
  type        = map(string)
  default     = {}
}

variable "task_managed_policy_arns" {
  description = "List of AWS managed policy ARNs for task role"
  type        = list(string)
  default     = []
}

# ============================================================================
# CLUSTER CONFIGURATION
# ============================================================================

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for detailed monitoring"
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "List of capacity providers (FARGATE, FARGATE_SPOT)"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy for the cluster"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  default = [
    {
      capacity_provider = "FARGATE"
      weight            = 100
      base              = 1
    }
  ]
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period (days)"
  type        = number
  default     = 7
}

variable "cloudwatch_kms_key_id" {
  description = "KMS key ID for encrypting CloudWatch Logs"
  type        = string
  default     = null
}

# ============================================================================
# TASK DEFINITION - COMPUTE
# ============================================================================

variable "task_cpu" {
  description = "CPU units for the task"
  type        = number
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = number
}

# ============================================================================
# CONTAINER DEFINITION
# ============================================================================

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image to use for ECS tasks"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "environment_variables" {
  description = "Environment variables for the container (non-sensitive)"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets from Secrets Manager or SSM Parameter Store (name => arn)"
  type        = map(string)
  default     = {}
}

variable "container_health_check" {
  description = "Container health check configuration"
  type = object({
    command     = list(string)
    interval    = number
    timeout     = number
    retries     = number
    startPeriod = number
  })
  default = null
}

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

# ============================================================================
# LOAD BALANCER
# ============================================================================

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group (null to disable ALB integration)"
  type        = string
  default     = null
}

# ============================================================================
# SERVICE CONFIGURATION
# ============================================================================

variable "desired_count" {
  description = "Desired number of tasks to run"
  type        = number
  default     = 2
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during deployment"
  type        = number
  default     = 50
}

variable "deployment_maximum_percent" {
  description = "Maximum percent during deployment"
  type        = number
  default     = 200
}

variable "enable_circuit_breaker" {
  description = "Enable deployment circuit breaker"
  type        = bool
  default     = true
}

variable "enable_circuit_breaker_rollback" {
  description = "Enable automatic rollback when circuit breaker triggers"
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for interactive debugging"
  type        = bool
  default     = false
}
