# Elastic Container Service

> Terraform module that provisions the ECS resources needed to run a containerized service.

---

## What it does

- creates ECS cluster resources
- creates task definition and service resources
- supports ALB integration for inbound traffic
- supports IAM integration for task execution and runtime permissions
- exposes ECS identifiers used by monitoring and deployment workflows

---

## Usage

```hcl
module "ecs" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/ecs?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
}
```

---

## Notes

- this module is intended for ECS standalone blueprint patterns
- consumers typically combine it with `ecr`, `alb`, `iam`, `secrets-manager`, and `monitoring`

---

<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_execution_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.task_execution_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| container\_image | Docker image to use for ECS tasks | `string` | n/a | yes |
| container\_port | Port the container listens on | `number` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| security\_group\_ids | List of security group IDs for ECS tasks | `list(string)` | n/a | yes |
| subnet\_ids | List of subnet IDs for ECS tasks | `list(string)` | n/a | yes |
| task\_cpu | CPU units for the task | `number` | n/a | yes |
| task\_memory | Memory for the task in MB | `number` | n/a | yes |
| alb\_target\_group\_arn | ARN of the ALB target group (null to disable ALB integration) | `string` | `null` | no |
| assign\_public\_ip | Assign public IP to tasks | `bool` | `false` | no |
| capacity\_providers | List of capacity providers (FARGATE, FARGATE\_SPOT) | `list(string)` | <pre>[<br/>  "FARGATE"<br/>]</pre> | no |
| cloudwatch\_kms\_key\_id | KMS key ID for encrypting CloudWatch Logs | `string` | `null` | no |
| container\_health\_check | Container health check configuration | <pre>object({<br/>    command     = list(string)<br/>    interval    = number<br/>    timeout     = number<br/>    retries     = number<br/>    startPeriod = number<br/>  })</pre> | `null` | no |
| container\_name | Name of the container | `string` | `"app"` | no |
| default\_capacity\_provider\_strategy | Default capacity provider strategy for the cluster | <pre>list(object({<br/>    capacity_provider = string<br/>    weight            = number<br/>    base              = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "base": 1,<br/>    "capacity_provider": "FARGATE",<br/>    "weight": 100<br/>  }<br/>]</pre> | no |
| deployment\_maximum\_percent | Maximum percent during deployment | `number` | `200` | no |
| deployment\_minimum\_healthy\_percent | Minimum healthy percent during deployment | `number` | `50` | no |
| desired\_count | Desired number of tasks to run | `number` | `2` | no |
| enable\_circuit\_breaker | Enable deployment circuit breaker | `bool` | `true` | no |
| enable\_circuit\_breaker\_rollback | Enable automatic rollback when circuit breaker triggers | `bool` | `true` | no |
| enable\_container\_insights | Enable CloudWatch Container Insights for detailed monitoring | `bool` | `true` | no |
| enable\_execute\_command | Enable ECS Exec for interactive debugging | `bool` | `false` | no |
| enable\_secrets\_access | Enable Secrets Manager and SSM Parameter Store access for task execution role | `bool` | `true` | no |
| environment\_variables | Environment variables for the container (non-sensitive) | `map(string)` | `{}` | no |
| kms\_key\_arns | List of KMS key ARNs for decrypting secrets | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| log\_retention\_days | CloudWatch Logs retention period (days) | `number` | `7` | no |
| permissions\_boundary\_arn | ARN of the permissions boundary policy | `string` | `null` | no |
| secrets | Secrets from Secrets Manager or SSM Parameter Store (name => arn) | `map(string)` | `{}` | no |
| secrets\_manager\_arns | List of Secrets Manager secret ARNs that task execution role can access | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| tags | Common tags to apply to all resources | `map(string)` | `{}` | no |
| task\_custom\_policies | Map of custom IAM policies for task role (policy\_name => policy\_json) | `map(string)` | `{}` | no |
| task\_managed\_policy\_arns | List of AWS managed policy ARNs for task role | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | ARN of the ECS cluster |
| cluster\_id | ID of the ECS cluster |
| cluster\_name | Name of the ECS cluster |
| log\_group\_arn | ARN of the CloudWatch log group |
| log\_group\_name | Name of the CloudWatch log group |
| service\_arn | ARN of the ECS service |
| service\_id | ID of the ECS service |
| service\_name | Name of the ECS service |
| task\_definition\_arn | ARN of the task definition (includes revision) |
| task\_definition\_family | Family name of the task definition |
| task\_definition\_revision | Revision number of the task definition |
| task\_execution\_role\_arn | ARN of the ECS task execution role |
| task\_execution\_role\_name | Name of the ECS task execution role |
| task\_role\_arn | ARN of the ECS task role |
| task\_role\_name | Name of the ECS task role |
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
