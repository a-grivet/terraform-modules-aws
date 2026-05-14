# Security-Groups

> Terraform module that creates security groups and associated ingress or egress rules for common blueprint patterns.

---

## What it does

- creates one or more security groups
- creates managed ingress and egress rules
- supports separation of application, load balancer, and data-layer traffic flows
- exposes security group identifiers for downstream module wiring

---

## Usage

```hcl
module "security_groups" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/security-groups?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
  vpc_id       = "vpc-0123456789abcdef0"
}
```

---

## Notes

- this module is meant to standardize traffic rules that were previously duplicated across blueprints
- consumers typically connect its outputs into ALB, ASG, ECS, Aurora, and ElastiCache modules

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
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.alb_to_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.app_to_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.app_to_internet_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.app_to_internet_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.app_to_redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.redis_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.app_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.app_ssh_from_bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.db_from_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.db_from_bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.redis_from_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| vpc\_id | VPC ID where security groups will be created | `string` | n/a | yes |
| allowed\_cidr\_blocks | CIDR blocks allowed to access the ALB | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| app\_port | Application port where backend services listen | `number` | `80` | no |
| bastion\_security\_group\_id | Security group ID of bastion host (required if bastion access is enabled) | `string` | `""` | no |
| db\_port | Database port | `number` | `3306` | no |
| enable\_db\_bastion\_access | Enable database access from bastion for troubleshooting | `bool` | `false` | no |
| enable\_https | Enable HTTPS ingress on the ALB security group | `bool` | `true` | no |
| enable\_redis | Whether to create a dedicated Redis security group | `bool` | `false` | no |
| enable\_ssh\_bastion | Enable SSH access from bastion to app tier | `bool` | `false` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| redis\_port | Redis port | `number` | `6379` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_security\_group\_arn | ARN of the ALB security group |
| alb\_security\_group\_id | ID of the ALB security group |
| alb\_security\_group\_name | Name of the ALB security group |
| all\_security\_group\_ids | Map of all security group IDs |
| app\_security\_group\_arn | ARN of the application security group |
| app\_security\_group\_id | ID of the application security group |
| app\_security\_group\_name | Name of the application security group |
| app\_sg\_arn | Compatibility alias for the application security group ARN |
| app\_sg\_id | Compatibility alias for the application security group ID |
| app\_sg\_name | Compatibility alias for the application security group name |
| db\_security\_group\_arn | ARN of the database security group |
| db\_security\_group\_id | ID of the database security group |
| db\_security\_group\_name | Name of the database security group |
| redis\_security\_group\_arn | ARN of the Redis security group |
| redis\_security\_group\_id | ID of the Redis security group |
| redis\_security\_group\_name | Name of the Redis security group |
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
