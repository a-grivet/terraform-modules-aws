# ============================================================================
# RDS AURORA MODULE - main.tf
# ============================================================================
# This module creates and manages an Amazon Aurora database cluster with high
# availability, automatic backups, and optional read replicas.
#
# Architecture:
# - Cluster: Central management entity (one per database)
# - Writer Instance: Handles all write operations
# - Reader Instances: Handle read-only operations
# - Endpoints: cluster_endpoint (write), reader_endpoint (read load-balanced)
#
# Key Features:
# - High Availability: Multi-AZ deployment with automatic failover
# - Backup: Continuous backup to S3, point-in-time recovery (5-minute granularity)
# - Encryption: At-rest (KMS) and in-transit (TLS/SSL)
# - Monitoring: Performance Insights, Enhanced Monitoring, CloudWatch logs
# - Scaling: Add read replicas for read-heavy workloads
# ============================================================================

# ============================================================================
# DB SUBNET GROUP - Define Network Placement
# ============================================================================
# Subnet group defines which subnets Aurora can use for database instances.
# Aurora automatically places instances across multiple Availability Zones.

resource "aws_db_subnet_group" "this" {
  name_prefix = "${local.name_prefix}-" # Auto-incremented name
  description = "Subnet group for ${var.app_id} Aurora cluster"
  subnet_ids  = var.db_subnet_ids # Private subnets across multiple AZs

  # Multi-AZ deployment:
  # - If writer fails, Aurora promotes a reader in a different AZ
  # - Failover takes < 30 seconds (DNS endpoint switches automatically)

  tags = merge(
    var.tags,
    {
      Name        = "${local.name_prefix}-db-subnet-group"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# ============================================================================
# DB PARAMETER GROUP (Cluster Level) - Database-Wide Configuration
# ============================================================================
# Cluster parameter group controls database wide settings that apply to the
# entire cluster (affects all instances: writer + readers).

resource "aws_rds_cluster_parameter_group" "this" {
  name_prefix = "${local.name_prefix}-cluster-"
  description = "Cluster parameter group for ${var.app_id}"

  # Determine parameter family based on engine and major version
  family = var.engine == "aurora-postgresql" ? "aurora-postgresql${split(".", var.engine_version)[0]}" : "aurora-mysql${split(".", var.engine_version)[0]}"

  # Dynamic block: create one parameter block per cluster parameter
  dynamic "parameter" {
    for_each = var.cluster_parameters # List of parameter objects

    content {
      name         = parameter.value.name                                 # Parameter name
      value        = parameter.value.value                                # Parameter value
      apply_method = lookup(parameter.value, "apply_method", "immediate") # When to apply: immediate or pending-reboot
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${local.name_prefix}-cluster-params"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  # Lifecycle management
  lifecycle {
    create_before_destroy = true # Create new parameter group before deleting old one
  }
}

# ============================================================================
# DB PARAMETER GROUP (Instance Level) - Per-Instance Configuration
# ============================================================================
# Instance parameter group controls settings specific to each database instance
# (can be different for writer vs readers if needed).

resource "aws_db_parameter_group" "this" {
  name_prefix = "${local.name_prefix}-instance-"
  description = "Instance parameter group for ${var.app_id}"
  family      = var.engine == "aurora-postgresql" ? "aurora-postgresql${split(".", var.engine_version)[0]}" : "aurora-mysql${split(".", var.engine_version)[0]}"

  # Dynamic block: create one parameter block per instance parameter
  dynamic "parameter" {
    for_each = var.instance_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${local.name_prefix}-instance-params"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# AURORA CLUSTER - Main Database Cluster Resource
# ============================================================================
# The Aurora cluster is the central management entity coordinating all database
# instances, storage, backups, and failover.

resource "aws_rds_cluster" "this" {
  cluster_identifier_prefix = "${local.name_prefix}-" # Cluster name prefix

  # ===== ENGINE CONFIGURATION =====
  engine         = var.engine         # aurora-postgresql or aurora-mysql
  engine_version = var.engine_version # Database version (e.g., "17.4")
  engine_mode    = var.engine_mode    # provisioned (standard) or serverless (auto-scaling)

  # Engine modes:
  # - provisioned: Fixed instance sizes (predictable cost, best for steady workloads)
  # - serverless: Auto-scales capacity (pay per use, best for variable workloads)

  # ===== DATABASE CREDENTIALS =====
  database_name   = var.database_name   # Default database name
  master_username = var.master_username # Admin username
  master_password = var.master_password # Admin password (rotate via Secrets Manager)
  port            = var.port            # 5432 (PostgreSQL) or 3306 (MySQL)

  # IMPORTANT: Store passwords in AWS Secrets Manager, not in code!
  # Secrets Manager provides:
  # - Automatic rotation
  # - Encryption at rest
  # - Audit logging

  # ===== NETWORK CONFIGURATION =====
  db_subnet_group_name   = aws_db_subnet_group.this.name # Which subnets to use
  vpc_security_group_ids = var.db_security_group_ids     # Firewall rules

  # Security best practices:
  # - Deploy in private subnets
  # - Security groups allow only necessary ports
  # - Restrict source IPs to application servers only

  # ===== AVAILABILITY ZONES =====
  availability_zones = var.availability_zones

  # Aurora automatically distributes instances across AZs for high availability

  # ===== BACKUP CONFIGURATION =====
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  # Backup strategy:
  # - Continuous backup to S3
  # - Daily snapshot at backup_window
  # - Restore to any point within retention period

  # Best practices:
  # - backup_retention_period: 7 days (dev), 30 days (prod)
  # - Schedule backups during low-traffic periods (03:00-04:00 UTC)
  # - Maintenance windows: Sunday early morning (sun:04:00-sun:05:00)

  # Final snapshot on cluster deletion
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Why final snapshots?
  # - Safety net before deletion (can restore if deletion was accidental)
  # - Required for compliance/audit in many organizations
  # - No cost if deleted within retention period

  # ===== ENCRYPTION =====
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  # Encryption:
  # - At rest: Data on disk encrypted with KMS
  # - In transit: TLS/SSL connections (enforced via parameter groups)
  # - Cannot disable encryption after cluster creation (immutable)

  # Best practice: Use custom KMS key for centralized key management

  # ===== MONITORING =====
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # ===== PARAMETER GROUPS =====
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  # ===== DELETION PROTECTION =====
  deletion_protection = var.deletion_protection

  # Deletion protection:
  # - Must explicitly disable before deletion
  # - Protects against accidental deletion
  # - Recommended: true for production

  # ===== SERVERLESS V2 SCALING (OPTIONAL) =====
  # Serverless v2 allows capacity to auto-scale between min and max ACUs
  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.engine_mode == "provisioned" && var.enable_serverless_v2_scaling ? [1] : []

    content {
      min_capacity = var.serverless_v2_min_capacity # Minimum Aurora Capacity Units (ACUs)
      max_capacity = var.serverless_v2_max_capacity # Maximum ACUs
    }
  }

  # Serverless v2:
  # - Capacity scales automatically based on load
  # - 1 ACU = 2GB RAM + proportional CPU
  # - min_capacity = 0.5 ACU (1GB RAM minimum)
  # - Scales in 0.5 ACU increments
  # - Best for: variable workloads, dev/test environments

  tags = merge(
    var.tags,
    {
      Name        = "${local.name_prefix}-aurora-cluster"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      availability_zones, # Aurora manages AZ placement dynamically
      master_password     # Password managed externally via Secrets Manager
    ]
  }
}

# ============================================================================
# AURORA WRITER INSTANCES - Handle Write Operations
# ============================================================================
# Writer instances handle all write operations.
# Aurora supports only ONE writer instance (multi-master not available).

resource "aws_rds_cluster_instance" "writer" {
  count = var.writer_instances # Typically 1 (Aurora limitation)

  identifier_prefix       = "${local.name_prefix}-writer-${count.index + 1}-"
  cluster_identifier      = aws_rds_cluster.this.id
  instance_class          = var.instance_class
  engine                  = aws_rds_cluster.this.engine
  engine_version          = aws_rds_cluster.this.engine_version
  db_parameter_group_name = aws_db_parameter_group.this.name

  # ===== ENHANCED MONITORING =====
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null

  # Enhanced monitoring:
  # - Provides OS-level metrics (CPU, memory, disk I/O, network)
  # - More detailed than CloudWatch basic metrics
  # - 60-second interval recommended

  # ===== PERFORMANCE INSIGHTS =====
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled && var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # ===== VERSION UPGRADES =====
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Auto upgrades:
  # - Minor versions: PostgreSQL 17.1 -> 17.2 (bug fixes, security patches)
  # - Occur during maintenance window (minimal downtime)
  # - Recommended: true (keeps database secure and stable)

  # ===== PUBLIC ACCESS =====
  publicly_accessible = false

  # Security best practice:
  # - Always deploy in private subnets
  # - Access via bastion host or VPN if needed
  # - Never set publicly_accessible = true in production

  tags = merge(
    var.tags,
    {
      Name        = "${local.name_prefix}-writer-${count.index + 1}"
      Environment = var.environment
      Role        = "writer"
      ManagedBy   = "terraform"
    }
  )
}

# ============================================================================
# AURORA READER INSTANCES - Handle Read Operations
# ============================================================================
# Reader instances handle read-only operations to offload
# the writer instance and improve overall database performance.

resource "aws_rds_cluster_instance" "reader" {
  count = var.reader_instances # 0-15 reader instances supported

  identifier_prefix       = "${local.name_prefix}-reader-${count.index + 1}-"
  cluster_identifier      = aws_rds_cluster.this.id
  instance_class          = var.reader_instance_class != "" ? var.reader_instance_class : var.instance_class
  engine                  = aws_rds_cluster.this.engine
  engine_version          = aws_rds_cluster.this.engine_version
  db_parameter_group_name = aws_db_parameter_group.this.name

  # Promotion tier (failover priority)
  promotion_tier = count.index + 1 # Lower number = higher priority

  # Promotion tier explained:
  # - Tier 0-15 (writer always has tier 0)
  # - On writer failure, Aurora promotes reader with lowest tier number
  # - reader 1: tier 1 (promoted first)
  # - reader 2: tier 2 (promoted second)
  # - Use case: place high-performance instances in lower tiers

  # ===== MONITORING (SAME AS WRITER) =====
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? var.monitoring_role_arn : null
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled && var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # ===== VERSION UPGRADES =====
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # ===== PUBLIC ACCESS =====
  publicly_accessible = false

  tags = merge(
    var.tags,
    {
      Name        = "${local.name_prefix}-reader-${count.index + 1}"
      Environment = var.environment
      Role        = "reader"
      ManagedBy   = "terraform"
    }
  )

  # Dependency: Wait for writer to be created before creating readers
  depends_on = [aws_rds_cluster_instance.writer]

  # Why depends_on?
  # - Ensures cluster has a writer before adding readers
  # - Prevents creation errors
  # - Best practice for Aurora multi-instance deployments
}
