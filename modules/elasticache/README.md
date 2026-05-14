# Elasticache

> Terraform module that provisions ElastiCache resources for application-side caching patterns.

---

## What it does

- creates the ElastiCache subnet group and cache resources
- supports Redis-based deployments
- supports encryption and tagging
- exposes identifiers used by application configuration and monitoring

---

## Usage

```hcl
module "elasticache" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/elasticache?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
}
```

---

## Notes

- this module is intended as the shared cache building block for blueprints that need Redis
- consumers often pair it with `security-groups`, `kms`, and `monitoring`

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
| [aws_elasticache_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group) | resource |
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| node\_type | ElastiCache node type for Redis nodes | `string` | n/a | yes |
| num\_cache\_nodes | Number of cache nodes (1 = no replica, 2+ = HA with replicas) | `number` | n/a | yes |
| redis\_security\_group\_id | Security group ID for Redis (from security-groups module) | `string` | n/a | yes |
| subnet\_ids | List of subnet IDs for Redis (private subnets) | `list(string)` | n/a | yes |
| at\_rest\_encryption\_enabled | Enable encryption at rest | `bool` | `true` | no |
| auth\_token | Auth token for Redis (required if transit\_encryption\_enabled is true) | `string` | `null` | no |
| automatic\_failover\_enabled | Enable automatic failover (requires num\_cache\_nodes >= 2) | `bool` | `false` | no |
| kms\_key\_id | KMS key ID for encryption at rest | `string` | `null` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| maintenance\_window | Weekly maintenance window in UTC | `string` | `"sun:05:00-sun:07:00"` | no |
| maxmemory\_policy | Eviction policy when memory is full | `string` | `"allkeys-lru"` | no |
| multi\_az\_enabled | Enable Multi-AZ deployment (requires automatic\_failover\_enabled = true) | `bool` | `false` | no |
| notification\_topic\_arn | SNS topic ARN for notifications | `string` | `null` | no |
| parameter\_group\_family | Redis parameter group family (must match redis\_version) | `string` | `"redis7"` | no |
| port | Redis port | `number` | `6379` | no |
| redis\_version | Redis engine version | `string` | `"7.1"` | no |
| snapshot\_retention\_limit | Number of days to retain snapshots (0 = disabled) | `number` | `1` | no |
| snapshot\_window | Daily backup window in UTC (for example 03:00-05:00) | `string` | `"03:00-05:00"` | no |
| tags | Common tags | `map(string)` | `{}` | no |
| timeout | Close connection after client is idle for N seconds (0 = disabled) | `number` | `300` | no |
| transit\_encryption\_enabled | Enable encryption in transit (TLS) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| configuration\_endpoint | Configuration endpoint (for cluster mode) |
| connection\_string | Redis connection string |
| engine\_version | Redis engine version |
| member\_clusters | List of member cluster IDs |
| node\_type | Node type |
| num\_cache\_nodes | Number of cache nodes |
| port | Redis port |
| primary\_endpoint | Primary endpoint for Redis (read/write) |
| reader\_endpoint | Reader endpoint for Redis (read-only) |
| replication\_group\_arn | Replication group ARN |
| replication\_group\_id | Replication group ID |
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
