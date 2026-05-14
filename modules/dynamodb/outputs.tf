# ============================================================================
# DYNAMODB MODULE - outputs.tf
# ============================================================================

# ===== TABLE INFORMATION =====

output "table_names" {
  description = "Map of logical table names to actual DynamoDB table names"
  value = {
    for table_name, table in aws_dynamodb_table.this :
    table_name => table.name
  }
}

output "table_arns" {
  description = "Map of table names to ARNs"
  value = {
    for table_name, table in aws_dynamodb_table.this :
    table_name => table.arn
  }
}

output "table_ids" {
  description = "Map of table names to IDs"
  value = {
    for table_name, table in aws_dynamodb_table.this :
    table_name => table.id
  }
}

# ===== STREAM INFORMATION =====

output "stream_arns" {
  description = "Map of table names to stream ARNs (if streams are enabled)"
  value = {
    for table_name, table in aws_dynamodb_table.this :
    table_name => table.stream_arn
    if table.stream_arn != null
  }
}

output "stream_labels" {
  description = "Map of table names to stream labels"
  value = {
    for table_name, table in aws_dynamodb_table.this :
    table_name => table.stream_label
    if table.stream_label != null
  }
}

# ===== CONSOLIDATED OUTPUT =====

output "tables" {
  description = "Consolidated information about all DynamoDB tables"
  value = {
    for table_name, table in aws_dynamodb_table.this :
    table_name => {
      name           = table.name
      arn            = table.arn
      id             = table.id
      hash_key       = table.hash_key
      range_key      = table.range_key
      billing_mode   = table.billing_mode
      stream_arn     = table.stream_arn
      stream_label   = table.stream_label
      read_capacity  = table.read_capacity
      write_capacity = table.write_capacity
    }
  }
}
