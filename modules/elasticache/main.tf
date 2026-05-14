# ============================================================================
# ELASTICACHE REDIS MODULE - main.tf
# ============================================================================
# This module creates an ElastiCache Redis replication group for caching and
# session storage.
#
# Architecture:
# - primary node (read/write) plus optional replicas
# - optional automatic failover for high availability
# - encryption at rest and in transit
# - daily backups with configurable retention
#
# Note: the Redis security group is expected to be created by the centralized
# security-groups module and passed in as input.
# ============================================================================

# ============================================================================
# REDIS SUBNET GROUP
# ============================================================================

resource "aws_elasticache_subnet_group" "this" {
  name        = "${local.name_prefix}-redis-subnet"
  description = "Subnet group for Redis cluster"
  subnet_ids  = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-redis-subnet"
    }
  )
}

# ============================================================================
# REDIS PARAMETER GROUP
# ============================================================================

resource "aws_elasticache_parameter_group" "this" {
  name   = "${local.name_prefix}-redis-params"
  family = var.parameter_group_family

  description = "Parameter group for Redis ${var.redis_version}"

  # Eviction policy controls what Redis does when memory is full.
  parameter {
    name  = "maxmemory-policy"
    value = var.maxmemory_policy
  }

  # Close idle client connections after the configured timeout.
  parameter {
    name  = "timeout"
    value = var.timeout
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-redis-params"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# REDIS REPLICATION GROUP
# ============================================================================

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${local.name_prefix}-redis"
  description          = "Redis cluster for ${local.name_prefix}"

  # Engine configuration.
  engine               = "redis"
  engine_version       = var.redis_version
  port                 = var.port
  parameter_group_name = aws_elasticache_parameter_group.this.name

  # Node configuration.
  node_type          = var.node_type
  num_cache_clusters = var.num_cache_nodes

  # Network configuration.
  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [var.redis_security_group_id]

  # High availability features only make sense when a replica exists.
  automatic_failover_enabled = var.num_cache_nodes > 1 ? var.automatic_failover_enabled : false
  multi_az_enabled           = var.num_cache_nodes > 1 ? var.multi_az_enabled : false

  # Security - encryption at rest.
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  kms_key_id                 = var.kms_key_id

  # Security - encryption in transit.
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.transit_encryption_enabled ? var.auth_token : null

  # Backup and maintenance windows.
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window

  # Notifications.
  notification_topic_arn = var.notification_topic_arn

  auto_minor_version_upgrade = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-redis"
    }
  )
}
