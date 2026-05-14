# ============================================================================
# ELASTICACHE REDIS MODULE - outputs.tf
# ============================================================================

# ===== CONNECTION ENDPOINTS =====

output "primary_endpoint" {
  description = "Primary endpoint for Redis (read/write)"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Reader endpoint for Redis (read-only)"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "configuration_endpoint" {
  description = "Configuration endpoint (for cluster mode)"
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}

output "port" {
  description = "Redis port"
  value       = var.port
}

# ===== CONNECTION STRING =====

output "connection_string" {
  description = "Redis connection string"
  value       = "redis://${aws_elasticache_replication_group.this.primary_endpoint_address}:${var.port}"
  sensitive   = true
}

# ===== RESOURCE IDENTIFIERS =====

output "replication_group_id" {
  description = "Replication group ID"
  value       = aws_elasticache_replication_group.this.id
}

output "replication_group_arn" {
  description = "Replication group ARN"
  value       = aws_elasticache_replication_group.this.arn
}

# ===== MEMBER NODES =====

output "member_clusters" {
  description = "List of member cluster IDs"
  value       = aws_elasticache_replication_group.this.member_clusters
}

# ===== CONFIGURATION =====

output "engine_version" {
  description = "Redis engine version"
  value       = aws_elasticache_replication_group.this.engine_version_actual
}

output "node_type" {
  description = "Node type"
  value       = var.node_type
}

output "num_cache_nodes" {
  description = "Number of cache nodes"
  value       = var.num_cache_nodes
}
