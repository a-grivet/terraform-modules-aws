# ============================================================================
# ASG MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the Auto Scaling Group module.
# Variables control instance configuration, capacity, scaling policies, and
# monitoring.
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES - Must Be Provided
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

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ASG instances will be deployed"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "At least one private subnet ID must be provided."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to instances"
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID must be provided."
  }
}

# ============================================================================
# CAPACITY VARIABLES - Control Instance Count
# ============================================================================

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1

  validation {
    condition     = var.min_size >= 0
    error_message = "Minimum size must be greater than or equal to 0."
  }
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3

  validation {
    condition     = var.max_size > 0
    error_message = "Maximum size must be greater than 0."
  }
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_capacity >= 0
    error_message = "Desired capacity must be greater than or equal to 0."
  }
}

# ============================================================================
# INSTANCE CONFIGURATION - Define Instance Properties
# ============================================================================

variable "ami_id" {
  description = "AMI ID to use for instances (defaults to latest Amazon Linux 2023 if empty)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?\\.", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "key_name" {
  description = "EC2 key pair name for SSH access (leave empty for no SSH key)"
  type        = string
  default     = ""
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name to attach to instances"
  type        = string
  default     = ""
}

# ============================================================================
# USER DATA - Instance Initialization Script
# ============================================================================

variable "user_data_script" {
  description = "User data script to run on instance launch (plain text)"
  type        = string
  default     = ""
}

variable "user_data_base64" {
  description = "User data script to run on instance launch (base64 encoded). Takes precedence over user_data_script if provided."
  type        = string
  default     = ""
}

# ============================================================================
# STORAGE CONFIGURATION - EBS Volume Settings
# ============================================================================

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 and 16384 GB."
  }
}

variable "root_volume_type" {
  description = "Type of root volume (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp3", "gp2", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be one of: gp3, gp2, io1, io2."
  }
}

variable "ebs_encryption_enabled" {
  description = "Enable EBS encryption for volumes when no custom KMS key is provided"
  type        = bool
  default     = true
}

# ============================================================================
# INSTANCE SETTINGS - Additional Configuration
# ============================================================================

variable "detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (additional cost)"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}

variable "require_imdsv2" {
  description = "Require IMDSv2 for instance metadata (recommended for security)"
  type        = bool
  default     = true
}

# ============================================================================
# HEALTH CHECK CONFIGURATION - Instance Health Monitoring
# ============================================================================

variable "health_check_type" {
  description = "Health check type: EC2 or ELB"
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "Health check type must be either EC2 or ELB."
  }
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance launch before health checks start"
  type        = number
  default     = 300

  validation {
    condition     = var.health_check_grace_period >= 0
    error_message = "Health check grace period must be greater than or equal to 0."
  }
}

# ============================================================================
# SCALING CONFIGURATION - ASG Behavior Settings
# ============================================================================

variable "termination_policies" {
  description = "List of termination policies for ASG"
  type        = list(string)
  default     = ["Default"]
}

variable "wait_for_capacity_timeout" {
  description = "Maximum time to wait for ASG capacity (0 = no wait)"
  type        = string
  default     = "10m"
}

variable "launch_template_version" {
  description = "Launch template version to use ($Latest, $Default, or version number)"
  type        = string
  default     = "$Latest"
}

# ============================================================================
# LOAD BALANCER INTEGRATION - ALB/NLB Connection
# ============================================================================

variable "target_group_arns" {
  description = "List of target group ARNs to attach to ASG (for ALB/NLB integration)"
  type        = list(string)
  default     = null
}

# ============================================================================
# INSTANCE REFRESH - Zero-Downtime Updates
# ============================================================================

variable "enable_instance_refresh" {
  description = "Enable instance refresh for rolling updates"
  type        = bool
  default     = true
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Minimum healthy percentage during instance refresh"
  type        = number
  default     = 90

  validation {
    condition     = var.instance_refresh_min_healthy_percentage >= 0 && var.instance_refresh_min_healthy_percentage <= 100
    error_message = "Min healthy percentage must be between 0 and 100."
  }
}

variable "instance_refresh_instance_warmup" {
  description = "Number of seconds until a newly launched instance is configured and ready to use"
  type        = number
  default     = 300
}

# ============================================================================
# METRICS AND MONITORING - CloudWatch Data Collection
# ============================================================================

variable "enabled_metrics" {
  description = "List of metrics to enable for ASG"
  type        = list(string)
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
}

# ============================================================================
# AUTO SCALING POLICIES - Automatic Capacity Adjustment
# ============================================================================

variable "enable_cpu_target_tracking" {
  description = "Enable CPU-based target tracking scaling policy"
  type        = bool
  default     = true
}

variable "cpu_target_tracking_target" {
  description = "Target CPU utilization percentage for target tracking"
  type        = number
  default     = 70

  validation {
    condition     = var.cpu_target_tracking_target > 0 && var.cpu_target_tracking_target <= 100
    error_message = "CPU target must be between 0 and 100."
  }
}

variable "enable_alb_target_tracking" {
  description = "Enable ALB request count target tracking scaling policy"
  type        = bool
  default     = false
}

variable "alb_target_tracking_target" {
  description = "Target number of requests per target for ALB-based scaling"
  type        = number
  default     = 1000
}

variable "alb_target_tracking_resource_label" {
  description = "Resource label for ALB target tracking (format: app/load-balancer-name/id/targetgroup/target-group-name/id)"
  type        = string
  default     = ""
}

# ============================================================================
# CLOUDWATCH ALARMS - Alerting Configuration
# ============================================================================

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for ASG monitoring"
  type        = bool
  default     = true
}

variable "high_cpu_threshold" {
  description = "CPU threshold (%) to trigger high CPU alarm"
  type        = number
  default     = 80

  validation {
    condition     = var.high_cpu_threshold > 0 && var.high_cpu_threshold <= 100
    error_message = "High CPU threshold must be between 0 and 100."
  }
}

variable "low_cpu_threshold" {
  description = "CPU threshold (%) to trigger low CPU alarm (cost optimization)"
  type        = number
  default     = 20

  validation {
    condition     = var.low_cpu_threshold >= 0 && var.low_cpu_threshold < 100
    error_message = "Low CPU threshold must be between 0 and 100."
  }
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

# ============================================================================
# TAGS - Resource Organization
# ============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# KMS ENCRYPTION KEYS
# ============================================================================

variable "ebs_kms_key_id" {
  description = "KMS key ID/ARN for EBS volume encryption. If provided, a KMS Grant will be automatically created for Auto Scaling service"
  type        = string
  default     = ""
}

variable "ami_kms_key_id" {
  description = "KMS key ID/ARN used to encrypt the AMI. Required for Auto Scaling to decrypt the AMI snapshot. Default is Organization Golden AMI shared key."
  type        = string
  default     = "arn:aws:kms:eu-west-1:xxxxxxxxxxxx:key/mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  # Replace xxxxxxxxxxxx with the AWS account ID and mrk-xxx with your Golden AMI KMS key ID
}
