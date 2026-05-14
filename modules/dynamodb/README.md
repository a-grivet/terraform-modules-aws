# DynamoDB

> Terraform module that provisions DynamoDB tables for shared application or infrastructure use cases.

---

## What it does

- creates DynamoDB tables with configurable billing and key schema
- supports optional secondary indexes when required by the workload
- supports encryption and tagging
- exposes table identifiers for downstream integrations

---

## Usage

```hcl
module "dynamodb" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/dynamodb?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
  table_name   = "my-app-dev-table"
}
```

---

## Notes

- this module is intentionally generic so it can cover multiple DynamoDB-backed patterns
- the generated documentation below is the source of truth for supported table options

---

<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7.4 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| autoscaling\_read\_max | Maximum read capacity for auto-scaling | `number` | `100` | no |
| autoscaling\_read\_min | Minimum read capacity for auto-scaling | `number` | `5` | no |
| autoscaling\_read\_target | Target utilization percentage for read capacity (1-100) | `number` | `70` | no |
| autoscaling\_write\_max | Maximum write capacity for auto-scaling | `number` | `100` | no |
| autoscaling\_write\_min | Minimum write capacity for auto-scaling | `number` | `5` | no |
| autoscaling\_write\_target | Target utilization percentage for write capacity (1-100) | `number` | `70` | no |
| enable\_autoscaling | Enable auto-scaling for PROVISIONED tables | `bool` | `false` | no |
| kms\_key\_id | KMS key ID for encryption at rest (if not provided, AWS managed key is used) | `string` | `null` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| tables | Map of DynamoDB tables to create | <pre>map(object({<br/>    billing_mode   = optional(string, "PAY_PER_REQUEST")<br/>    read_capacity  = optional(number, 5)<br/>    write_capacity = optional(number, 5)<br/><br/>    hash_key      = string<br/>    hash_key_type = optional(string, "S")<br/><br/>    range_key      = optional(string, null)<br/>    range_key_type = optional(string, "S")<br/><br/>    # Time-To-Live.<br/>    ttl_enabled        = optional(bool, false)<br/>    ttl_attribute_name = optional(string, "ttl")<br/><br/>    # Point-in-time recovery.<br/>    point_in_time_recovery = optional(bool, true)<br/><br/>    # Streams for event sourcing or triggers.<br/>    stream_enabled   = optional(bool, false)<br/>    stream_view_type = optional(string, "NEW_AND_OLD_IMAGES")<br/><br/>    # Global secondary indexes.<br/>    global_secondary_indexes = optional(list(object({<br/>      name               = string<br/>      hash_key           = string<br/>      hash_key_type      = optional(string, "S")<br/>      range_key          = optional(string, null)<br/>      range_key_type     = optional(string, "S")<br/>      projection_type    = optional(string, "ALL")<br/>      non_key_attributes = optional(list(string), [])<br/>      read_capacity      = optional(number, 5)<br/>      write_capacity     = optional(number, 5)<br/>    })), [])<br/><br/>    # Local secondary indexes.<br/>    local_secondary_indexes = optional(list(object({<br/>      name               = string<br/>      range_key          = string<br/>      range_key_type     = optional(string, "S")<br/>      projection_type    = optional(string, "ALL")<br/>      non_key_attributes = optional(list(string), [])<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| tags | Common tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| stream\_arns | Map of table names to stream ARNs (if streams are enabled) |
| stream\_labels | Map of table names to stream labels |
| table\_arns | Map of table names to ARNs |
| table\_ids | Map of table names to IDs |
| table\_names | Map of logical table names to actual DynamoDB table names |
| tables | Consolidated information about all DynamoDB tables |
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
