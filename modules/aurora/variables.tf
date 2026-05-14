# ============================================================================
# AURORA MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the RDS Aurora database module.
# Variables control engine type, instance sizing, backup/maintenance windows,
# encryption, monitoring, and high availability configuration.
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

variable "db_subnet_ids" {
  description = "List of subnet IDs for DB subnet group (minimum 2 in different AZs)"
  type        = list(string)

  # Input validation: ensure high availability with multiple AZs
  validation {
    condition     = length(var.db_subnet_ids) >= 2
    error_message = "At least 2 subnets in different AZs are required for Aurora."
  }
  # Aurora requires subnets in at least 2 Availability Zones for failover
  # Best practice: provide at least 2 subnets (one per AZ )
}

variable "db_security_group_ids" {
  description = "List of security group IDs to attach to the Aurora cluster"
  type        = list(string)
  # Security groups control inbound/outbound traffic (firewall rules)
  # Typically allow port 5432 (PostgreSQL) or 3306 (MySQL) from application servers
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  # Admin username for database access
  # Cannot be changed after cluster creation
  # Avoid using "admin", "root", or "postgres" (reserved words)
}

variable "master_password" {
  description = "Master password for the database (use Secrets Manager)"
  type        = string
  sensitive   = true
  # Admin password (marked sensitive to hide in logs)
  # Best practice: retrieve from AWS Secrets Manager, DON'T HARDCODE !
}

# ============================================================================
# ENGINE CONFIGURATION - Database Type and Version
# ============================================================================

variable "engine" {
  description = "Aurora engine type (aurora-postgresql or aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"

  # Input validation: restrict to supported engines
  validation {
    condition     = contains(["aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "Engine must be either 'aurora-postgresql' or 'aurora-mysql'."
  }
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "17.4"
}

variable "engine_mode" {
  description = "Engine mode (provisioned or serverless)"
  type        = string
  default     = "provisioned"

  # Input validation: restrict to supported modes
  validation {
    condition     = contains(["provisioned", "serverless"], var.engine_mode)
    error_message = "Engine mode must be either 'provisioned' or 'serverless'."
  }
  # Engine modes:
  # - provisioned: Fixed instance sizes (predictable cost, best for steady workloads)
  # - serverless: Auto-scales capacity (pay per use, best for variable/unpredictable workloads)
}

# ============================================================================
# DATABASE CONFIGURATION - Database Name and Connection
# ============================================================================

variable "database_name" {
  description = "Name of the default database to create"
  type        = string
  # Naming rules: alphanumeric and underscores only, no hyphens
}

variable "port" {
  description = "Database port (5432 for PostgreSQL, 3306 for MySQL)"
  type        = number
  default     = 5432
  # Standard ports:
  # - PostgreSQL: 5432
  # - MySQL: 3306
}

# ============================================================================
# INSTANCE CONFIGURATION - Instance Sizing and Count
# ============================================================================

variable "instance_class" {
  description = "Instance class for Aurora instances (e.g., db.t3.medium, db.r6g.large)"
  type        = string
  default     = "db.t3.medium"
  # Instance classes:
  # - db.t3.medium: 2 vCPU, 4GB RAM (general purpose, burstable, good for dev/staging)
  # - db.t4g.medium: 2 vCPU, 4GB RAM (ARM-based, 20% cheaper than t3)
  # - db.r6g.large: 2 vCPU, 16GB RAM (memory-optimized, production workloads)
  # - db.r6i.xlarge: 4 vCPU, 32GB RAM (memory-optimized, high-performance)
  #
  # Choosing instance class:
  # - Development: db.t3.medium or db.t4g.medium
  # - Production: db.r6g.large or larger (memory-optimized for database workloads)
}

variable "writer_instances" {
  description = "Number of writer instances (typically 1)"
  type        = number
  default     = 1

  # Input validation: Aurora limitation
  validation {
    condition     = var.writer_instances >= 1 && var.writer_instances <= 1
    error_message = "Aurora supports only 1 writer instance."
  }
  # Aurora architecture limitation: single writer, multiple readers
}

variable "reader_instances" {
  description = "Number of reader instances (0-15)"
  type        = number
  default     = 1

  # Input validation: ensure within AWS limits
  validation {
    condition     = var.reader_instances >= 0 && var.reader_instances <= 15
    error_message = "Reader instances must be between 0 and 15."
  }
}

variable "reader_instance_class" {
  description = "Instance class for reader instances (if different from writer). Leave empty to use same as writer"
  type        = string
  default     = ""
  # Use case: cheaper reader instances for less critical read workloads
  # Example: writer = db.r6g.xlarge, reader = db.r6g.large
  # Empty string = use same instance class as writer
}

# ============================================================================
# AVAILABILITY - Multi-AZ Deployment Configuration
# ============================================================================

variable "availability_zones" {
  description = "List of AZs for cluster placement (leave empty for automatic)"
  type        = list(string)
  default     = []
  # Aurora automatically distributes instances across AZs
}

# ============================================================================
# BACKUP & MAINTENANCE - Data Protection and Update Windows
# ============================================================================

variable "backup_retention_period" {
  description = "Backup retention period in days (1-35)"
  type        = number
  default     = 7

  # Input validation: ensure within AWS limits
  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
  # Backup strategy:
  # - 7 days: Development/staging
  # - 30 days: Production (recommended)
  # - 35 days: Maximum (compliance requirements)
  #
  # Aurora backups:
  # - Continuous backup to S3
  # - Daily snapshots (stored separately from continuous backups)
}

variable "preferred_backup_window" {
  description = "Preferred backup window (UTC, format: hh24:mi-hh24:mi)"
  type        = string
  default     = "03:00-04:00"
  # UTC time window for daily snapshots (1-hour window)
  # Schedule during low-traffic period
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window (UTC, format: ddd:hh24:mi-ddd:hh24:mi)"
  type        = string
  default     = "sun:04:00-sun:05:00"
  # UTC time window for system maintenance (1-hour minimum window)
  # AWS may apply patches, minor version upgrades during this window
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying cluster (not recommended for production)"
  type        = bool
  default     = false
  # Safety net before cluster deletion
  # - false (default): Create final snapshot before deletion
  # - true: Delete immediately without snapshot
  #
  # Use cases:
  # - Development: true (faster cleanup)
  # - Staging: false (may need to investigate issues)
  # - Production: false (ALWAYS create final snapshot)
}

# ============================================================================
# ENCRYPTION - Data Protection at Rest
# ============================================================================

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
  # Best practice: Always encrypt (true)
  # Encryption at rest:
  # - Protects data on disk (storage volumes, backups, snapshots)
}

variable "kms_key_id" {
  description = "KMS key ARN for storage encryption (leave empty for aws/rds)"
  type        = string
  default     = ""
  # Encryption key options:
  # - Empty string: Use AWS-managed key (aws/rds) - simple, no key management
  # - Custom KMS key ARN: Use customer-managed key - centralized key management
}

# ============================================================================
# MONITORING - Performance and Logging Configuration
# ============================================================================

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch (e.g., ['postgresql'] or ['error', 'general', 'slowquery'])"
  type        = list(string)
  default     = []
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60

  # Input validation: ensure valid interval
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30, or 60 seconds."
  }
  # Enhanced monitoring provides OS-level metrics:
  # - CPU utilization (user, system, idle)
  # - Memory (used, cached, buffers)
  # - Disk I/O (read/write throughput, IOPS)
  # - Network throughput
  #
  # Intervals:
  # - 0: Disabled (basic CloudWatch metrics only)
  # - 60: Recommended (good detail, low cost)
  # - 1: High granularity (expensive, troubleshooting only)
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring (required if monitoring_interval > 0)"
  type        = string
  default     = ""
  # IAM role must have rds-monitoring-role policy attached
  # Required permissions: CloudWatch PutMetricData
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
  # Performance Insights:
  # - Database performance monitoring and analysis
  # - Identifies slow queries, CPU bottlenecks, lock contention
  # - Visual dashboard showing top SQL, wait events, DB load
  # - Highly recommended for production databases
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ID for Performance Insights encryption (leave empty for default)"
  type        = string
  default     = ""
  # Encryption for Performance Insights data
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days (7, 731 for free tier, or custom)"
  type        = number
  default     = 7

  # Input validation: ensure valid retention period
  validation {
    condition     = var.performance_insights_retention_period == 7 || var.performance_insights_retention_period == 731 || var.performance_insights_retention_period >= 7
    error_message = "Performance Insights retention must be 7 (free) or 731+ days."
  }
}

# ============================================================================
# PROTECTION - Prevent Accidental Deletion and Auto-Updates
# ============================================================================

variable "deletion_protection" {
  description = "Enable deletion protection (recommended for production)"
  type        = bool
  default     = false
  # Deletion protection:
  # - Prevents accidental cluster deletion via API/console
  # - Must explicitly disable before deletion
  # - Recommended: true for production
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
  # Automatic minor version upgrades:
  # - Example: PostgreSQL 17.1 -> 17.2 (bug fixes, security patches)
  # - Occur during maintenance window
  # - Recommended: true (keeps database secure)
}

# ============================================================================
# PARAMETERS - Database Configuration Tuning
# ============================================================================

variable "cluster_parameters" {
  description = "List of cluster parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
  # Cluster-level parameters affect entire cluster (writer + readers)
  # Example (PostgreSQL):
  # [
  #   {
  #     name  = "rds.force_ssl"
  #     value = "1"
  #     apply_method = "immediate"
  #   }
  # ]
}

variable "instance_parameters" {
  description = "List of instance parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
  # Instance-level parameters affect individual instances
  # Can be different for writer vs readers
  # Example (PostgreSQL):
  # [
  #   {
  #     name  = "work_mem"
  #     value = "16384"
  #   }
  # ]
}

# ============================================================================
# SERVERLESS V2 - Auto-Scaling Configuration (Optional)
# ============================================================================

variable "enable_serverless_v2_scaling" {
  description = "Enable Serverless v2 scaling (requires provisioned engine_mode)"
  type        = bool
  default     = false
  # Serverless v2:
  # - Auto-scales capacity based on database load
  # - Works with provisioned engine mode
  # - Best for: variable workloads, cost optimization
}

variable "serverless_v2_min_capacity" {
  description = "Minimum Aurora Capacity Units (ACUs) for Serverless v2"
  type        = number
  default     = 0.5
  # 1 ACU = 2GB RAM + proportional CPU
  # Minimum: 0.5 ACU (1GB RAM)
  # Scales in 0.5 ACU increments
}

variable "serverless_v2_max_capacity" {
  description = "Maximum Aurora Capacity Units (ACUs) for Serverless v2"
  type        = number
  default     = 1.0
  # Maximum capacity during peak load
  # Example: 1.0 ACU = 2GB RAM
  # Cost optimization: set based on peak workload requirements
}

# ============================================================================
# TAGS - Resource Organization and Cost Tracking
# ============================================================================

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
  # Tags for organization, cost allocation, and automation
  # Example: { \"CostCenter\" = \"IT\", \"Owner\" = \"DatabaseTeam\" }
}
