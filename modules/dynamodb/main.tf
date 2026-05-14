# ============================================================================
# DYNAMODB MODULE - main.tf
# ============================================================================
# This module creates one or more DynamoDB tables with optional features:
# - pay-per-request or provisioned billing
# - global secondary indexes (GSI)
# - local secondary indexes (LSI)
# - DynamoDB Streams
# - point-in-time recovery
# - TTL (Time-To-Live)
# - KMS encryption
# - application auto-scaling for provisioned tables
# ============================================================================

# ============================================================================
# DYNAMODB TABLES
# ============================================================================

resource "aws_dynamodb_table" "this" {
  for_each = var.tables

  name         = "${local.name_prefix}-${each.key}"
  billing_mode = each.value.billing_mode

  # Capacity applies only to PROVISIONED mode.
  read_capacity  = each.value.billing_mode == "PROVISIONED" ? each.value.read_capacity : null
  write_capacity = each.value.billing_mode == "PROVISIONED" ? each.value.write_capacity : null

  # Primary keys.
  hash_key  = each.value.hash_key
  range_key = each.value.range_key

  # Attributes must include every key used by the table and its indexes.
  dynamic "attribute" {
    for_each = { for attr in local.all_attributes[each.key] : attr.name => attr if attr != null }
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global secondary indexes.
  dynamic "global_secondary_index" {
    for_each = each.value.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type

      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null

      read_capacity  = each.value.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity = each.value.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  # Local secondary indexes.
  dynamic "local_secondary_index" {
    for_each = each.value.local_secondary_indexes
    content {
      name            = local_secondary_index.value.name
      range_key       = local_secondary_index.value.range_key
      projection_type = local_secondary_index.value.projection_type

      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? local_secondary_index.value.non_key_attributes : null
    }
  }

  # Time-To-Live.
  dynamic "ttl" {
    for_each = each.value.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = each.value.ttl_attribute_name
    }
  }

  # Point-in-time recovery improves operational resilience for critical data.
  point_in_time_recovery {
    enabled = each.value.point_in_time_recovery
  }

  # Encryption at rest.
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.key}"
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}

# ============================================================================
# AUTO-SCALING (only for PROVISIONED billing mode)
# ============================================================================

resource "aws_appautoscaling_target" "read" {
  for_each = {
    for table_name, table_config in var.tables :
    table_name => table_config
    if var.enable_autoscaling && table_config.billing_mode == "PROVISIONED"
  }

  max_capacity       = var.autoscaling_read_max
  min_capacity       = var.autoscaling_read_min
  resource_id        = "table/${aws_dynamodb_table.this[each.key].name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read" {
  for_each = {
    for table_name, table_config in var.tables :
    table_name => table_config
    if var.enable_autoscaling && table_config.billing_mode == "PROVISIONED"
  }

  name               = "${local.name_prefix}-${each.key}-read-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.read[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.autoscaling_read_target
  }
}

resource "aws_appautoscaling_target" "write" {
  for_each = {
    for table_name, table_config in var.tables :
    table_name => table_config
    if var.enable_autoscaling && table_config.billing_mode == "PROVISIONED"
  }

  max_capacity       = var.autoscaling_write_max
  min_capacity       = var.autoscaling_write_min
  resource_id        = "table/${aws_dynamodb_table.this[each.key].name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write" {
  for_each = {
    for table_name, table_config in var.tables :
    table_name => table_config
    if var.enable_autoscaling && table_config.billing_mode == "PROVISIONED"
  }

  name               = "${local.name_prefix}-${each.key}-write-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.write[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.autoscaling_write_target
  }
}
