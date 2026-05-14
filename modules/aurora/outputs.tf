# ============================================================================
# AURORA MODULE OUTPUTS - outputs.tf
# ============================================================================
# This file defines output values that other modules or applications can use.
# Outputs provide connection information, resource identifiers, and configuration
# details for the Aurora database cluster.
#
# Key outputs:
# - Cluster endpoints (write and read endpoints for application connections)
# - Instance identifiers (for monitoring and management)
# - Connection strings (for easy application configuration)
# - Security and network details (for troubleshooting)
# ============================================================================

# ============================================================================
# CLUSTER IDENTIFICATION OUTPUTS
# ============================================================================
# Core identifiers for the Aurora cluster

output "cluster_id" {
  description = "ID of the Aurora cluster"
  value       = aws_rds_cluster.this.id
  # Cluster identifier (name)
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = aws_rds_cluster.this.arn
  # Amazon Resource Name (full identifier)
}

output "cluster_resource_id" {
  description = "Resource ID of the Aurora cluster"
  value       = aws_rds_cluster.this.cluster_resource_id
  # Unique cluster identifier
}

# ============================================================================
# CONNECTION ENDPOINTS OUTPUTS
# ============================================================================
# Database connection endpoints for applications

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster"
  value       = aws_rds_cluster.this.endpoint
  # Writer endpoint: Routes to the WRITER instance
  # Use this endpoint for: INSERT, UPDATE, DELETE operations
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint for the Aurora cluster"
  value       = aws_rds_cluster.this.reader_endpoint
  # Reader endpoint: Load-balances across ALL READER instances
}

output "cluster_port" {
  description = "Port on which the database accepts connections"
  value       = aws_rds_cluster.this.port
  # Database port number
  # - PostgreSQL: 5432
  # - MySQL: 3306
}

output "cluster_database_name" {
  description = "Name of the default database"
  value       = aws_rds_cluster.this.database_name
  # Name of the initial database created automatically
  # Additional databases can be created via SQL after connection
}

output "cluster_master_username" {
  description = "Master username for the database"
  value       = aws_rds_cluster.this.master_username
  sensitive   = true
  # Admin username
  # Use this username for initial database setup
  # Best practice: Create application-specific users after setup
}

# ============================================================================
# ENGINE INFORMATION OUTPUTS
# ============================================================================
# Database engine details

output "cluster_engine" {
  description = "Database engine"
  value       = aws_rds_cluster.this.engine
  # Engine type: \"aurora-postgresql\" or \"aurora-mysql\"
}

output "cluster_engine_version" {
  description = "Database engine version"
  value       = aws_rds_cluster.this.engine_version
  # Engine version (e.g., \"17.4\" for PostgreSQL)
}

output "cluster_hosted_zone_id" {
  description = "Route53 hosted zone ID for the endpoint"
  value       = aws_rds_cluster.this.hosted_zone_id
}

# ============================================================================
# WRITER INSTANCE OUTPUTS
# ============================================================================
# Information about writer instance

output "writer_instance_ids" {
  description = "IDs of writer instances"
  value       = aws_rds_cluster_instance.writer[*].id
  # List of writer instance identifiers
  # Only one writer (Aurora limitation)
}

output "writer_instance_endpoints" {
  description = "Endpoints of writer instances"
  value       = aws_rds_cluster_instance.writer[*].endpoint
  # Direct connection endpoints to writer instances
}

output "writer_instance_arns" {
  description = "ARNs of writer instances"
  value       = aws_rds_cluster_instance.writer[*].arn
  # Amazon Resource Names for writer instances
}

# ============================================================================
# READER INSTANCE OUTPUTS
# ============================================================================
# Information about reader instance(s)

output "reader_instance_ids" {
  description = "IDs of reader instances"
  value       = aws_rds_cluster_instance.reader[*].id
  # List of reader instance identifiers
}

output "reader_instance_endpoints" {
  description = "Endpoints of reader instances"
  value       = aws_rds_cluster_instance.reader[*].endpoint
  # Direct connection endpoints to reader instances
}

output "reader_instance_arns" {
  description = "ARNs of reader instances"
  value       = aws_rds_cluster_instance.reader[*].arn
  # Amazon Resource Names for reader instances
}

# ============================================================================
# CONNECTION STRING OUTPUTS
# ============================================================================
# Pre-formatted connection strings for easy application configuration

output "connection_string_writer" {
  description = "Connection string for writer endpoint (without password)"
  value       = "${var.engine == "aurora-postgresql" ? "postgresql" : "mysql"}://${aws_rds_cluster.this.master_username}@${aws_rds_cluster.this.endpoint}:${aws_rds_cluster.this.port}/${aws_rds_cluster.this.database_name}"
  sensitive   = true
}

output "connection_string_reader" {
  description = "Connection string for reader endpoint (without password)"
  value       = "${var.engine == "aurora-postgresql" ? "postgresql" : "mysql"}://${aws_rds_cluster.this.master_username}@${aws_rds_cluster.this.reader_endpoint}:${aws_rds_cluster.this.port}/${aws_rds_cluster.this.database_name}"
  sensitive   = true
  # Same format as writer connection string, but uses reader_endpoint
}

# ============================================================================
# SECURITY & NETWORK OUTPUTS
# ============================================================================
# Network and security configuration details

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.this.name
  # Subnet group name
}

output "db_subnet_group_arn" {
  description = "ARN of the DB subnet group"
  value       = aws_db_subnet_group.this.arn
  # Amazon Resource Name for the subnet group
}

output "security_group_ids" {
  description = "Security group IDs attached to the cluster"
  value       = var.db_security_group_ids
  # List of security group IDs controlling database access
}

# ============================================================================
# PARAMETER GROUPS OUTPUTS
# ============================================================================
# Database configuration parameter groups

output "cluster_parameter_group_name" {
  description = "Name of the cluster parameter group"
  value       = aws_rds_cluster_parameter_group.this.name
  # Cluster-level parameter group name
}

output "instance_parameter_group_name" {
  description = "Name of the instance parameter group"
  value       = aws_db_parameter_group.this.name
  # Instance-level parameter group name
}

# ============================================================================
# MONITORING OUTPUTS
# ============================================================================
# Monitoring and logging configuration status

output "performance_insights_enabled" {
  description = "Whether Performance Insights is enabled"
  value       = var.performance_insights_enabled
  # Boolean indicating if Performance Insights is active
  # true = database performance monitoring enabled
}

output "enhanced_monitoring_enabled" {
  description = "Whether enhanced monitoring is enabled"
  value       = var.monitoring_interval > 0
  # Boolean indicating if enhanced monitoring (OS-level metrics) is active
  # true = monitoring_interval > 0 (OS metrics collected)
  # false = monitoring_interval = 0 (basic CloudWatch only)
}

output "cloudwatch_log_group_names" {
  description = "CloudWatch log group names for exported logs"
  value = [
    for log_type in var.enabled_cloudwatch_logs_exports :
    "/aws/rds/cluster/${aws_rds_cluster.this.id}/${log_type}"
  ]
  # List of CloudWatch log group names where database logs are exported
}
