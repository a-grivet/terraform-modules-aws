# Aurora

> Terraform module that provisions an Aurora cluster with its instances, subnet group, and parameter groups.

---

## What it does

- creates an Aurora cluster
- creates writer and optional reader instances
- creates DB subnet and parameter groups
- supports encryption, backup, and maintenance configuration
- exposes connection endpoints for downstream modules

---

## Usage

```hcl
module "aurora" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/aurora?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
  subnet_ids   = ["subnet-aaa", "subnet-bbb"]
}
```

---

## Notes

- this module is intended as the shared Aurora building block for database-backed blueprints
- consumers often pair it with `secrets-manager`, `ssm-parameters`, `kms`, and `monitoring`

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
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_rds_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_instance.writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| database\_name | Name of the default database to create | `string` | n/a | yes |
| db\_security\_group\_ids | List of security group IDs to attach to the Aurora cluster | `list(string)` | n/a | yes |
| db\_subnet\_ids | List of subnet IDs for DB subnet group (minimum 2 in different AZs) | `list(string)` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| master\_password | Master password for the database (use Secrets Manager) | `string` | n/a | yes |
| master\_username | Master username for the database | `string` | n/a | yes |
| auto\_minor\_version\_upgrade | Enable automatic minor version upgrades | `bool` | `true` | no |
| availability\_zones | List of AZs for cluster placement (leave empty for automatic) | `list(string)` | `[]` | no |
| backup\_retention\_period | Backup retention period in days (1-35) | `number` | `7` | no |
| cluster\_parameters | List of cluster parameters to apply | <pre>list(object({<br/>    name         = string<br/>    value        = string<br/>    apply_method = optional(string, "immediate")<br/>  }))</pre> | `[]` | no |
| deletion\_protection | Enable deletion protection (recommended for production) | `bool` | `false` | no |
| enable\_serverless\_v2\_scaling | Enable Serverless v2 scaling (requires provisioned engine\_mode) | `bool` | `false` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to export to CloudWatch (e.g., ['postgresql'] or ['error', 'general', 'slowquery']) | `list(string)` | `[]` | no |
| engine | Aurora engine type (aurora-postgresql or aurora-mysql) | `string` | `"aurora-postgresql"` | no |
| engine\_mode | Engine mode (provisioned or serverless) | `string` | `"provisioned"` | no |
| engine\_version | Engine version | `string` | `"17.4"` | no |
| instance\_class | Instance class for Aurora instances (e.g., db.t3.medium, db.r6g.large) | `string` | `"db.t3.medium"` | no |
| instance\_parameters | List of instance parameters to apply | <pre>list(object({<br/>    name         = string<br/>    value        = string<br/>    apply_method = optional(string, "immediate")<br/>  }))</pre> | `[]` | no |
| kms\_key\_id | KMS key ARN for storage encryption (leave empty for aws/rds) | `string` | `""` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| monitoring\_interval | Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60) | `number` | `60` | no |
| monitoring\_role\_arn | IAM role ARN for enhanced monitoring (required if monitoring\_interval > 0) | `string` | `""` | no |
| performance\_insights\_enabled | Enable Performance Insights | `bool` | `true` | no |
| performance\_insights\_kms\_key\_id | KMS key ID for Performance Insights encryption (leave empty for default) | `string` | `""` | no |
| performance\_insights\_retention\_period | Performance Insights retention period in days (7, 731 for free tier, or custom) | `number` | `7` | no |
| port | Database port (5432 for PostgreSQL, 3306 for MySQL) | `number` | `5432` | no |
| preferred\_backup\_window | Preferred backup window (UTC, format: hh24:mi-hh24:mi) | `string` | `"03:00-04:00"` | no |
| preferred\_maintenance\_window | Preferred maintenance window (UTC, format: ddd:hh24:mi-ddd:hh24:mi) | `string` | `"sun:04:00-sun:05:00"` | no |
| reader\_instance\_class | Instance class for reader instances (if different from writer). Leave empty to use same as writer | `string` | `""` | no |
| reader\_instances | Number of reader instances (0-15) | `number` | `1` | no |
| serverless\_v2\_max\_capacity | Maximum Aurora Capacity Units (ACUs) for Serverless v2 | `number` | `1` | no |
| serverless\_v2\_min\_capacity | Minimum Aurora Capacity Units (ACUs) for Serverless v2 | `number` | `0.5` | no |
| skip\_final\_snapshot | Skip final snapshot when destroying cluster (not recommended for production) | `bool` | `false` | no |
| storage\_encrypted | Enable storage encryption | `bool` | `true` | no |
| tags | Additional tags to apply to resources | `map(string)` | `{}` | no |
| writer\_instances | Number of writer instances (typically 1) | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_group\_names | CloudWatch log group names for exported logs |
| cluster\_arn | ARN of the Aurora cluster |
| cluster\_database\_name | Name of the default database |
| cluster\_endpoint | Writer endpoint for the Aurora cluster |
| cluster\_engine | Database engine |
| cluster\_engine\_version | Database engine version |
| cluster\_hosted\_zone\_id | Route53 hosted zone ID for the endpoint |
| cluster\_id | ID of the Aurora cluster |
| cluster\_master\_username | Master username for the database |
| cluster\_parameter\_group\_name | Name of the cluster parameter group |
| cluster\_port | Port on which the database accepts connections |
| cluster\_reader\_endpoint | Reader endpoint for the Aurora cluster |
| cluster\_resource\_id | Resource ID of the Aurora cluster |
| connection\_string\_reader | Connection string for reader endpoint (without password) |
| connection\_string\_writer | Connection string for writer endpoint (without password) |
| db\_subnet\_group\_arn | ARN of the DB subnet group |
| db\_subnet\_group\_name | Name of the DB subnet group |
| enhanced\_monitoring\_enabled | Whether enhanced monitoring is enabled |
| instance\_parameter\_group\_name | Name of the instance parameter group |
| performance\_insights\_enabled | Whether Performance Insights is enabled |
| reader\_instance\_arns | ARNs of reader instances |
| reader\_instance\_endpoints | Endpoints of reader instances |
| reader\_instance\_ids | IDs of reader instances |
| security\_group\_ids | Security group IDs attached to the cluster |
| writer\_instance\_arns | ARNs of writer instances |
| writer\_instance\_endpoints | Endpoints of writer instances |
| writer\_instance\_ids | IDs of writer instances |
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
<!-- END_TF_DOCS -->
