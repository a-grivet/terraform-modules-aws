# Iam

> Terraform module that creates reusable IAM roles, policies, and attachments for blueprint workloads.

---

## What it does

- creates IAM roles for compute or service identities
- supports inline and managed policy attachments
- supports instance profile creation when EC2 integration is required
- exposes role and profile outputs for downstream modules

---

## Usage

```hcl
module "iam" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/iam?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
}
```

---

## Notes

- this module is intentionally generic so it can be reused for EC2, ECS, and supporting infrastructure roles
- consumers should rely on generated inputs below for the exact policy model supported by the module

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
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.custom_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| custom\_policies | Map of custom inline policies (name -> policy JSON) | `map(string)` | `{}` | no |
| enable\_cloudwatch | Enable CloudWatch Logs and Metrics access | `bool` | `true` | no |
| enable\_ssm | Enable AWS Systems Manager (SSM) access for Session Manager | `bool` | `true` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| managed\_policy\_arns | List of additional AWS managed policy ARNs to attach | `list(string)` | `[]` | no |
| max\_session\_duration | Maximum session duration in seconds (1h to 12h) | `number` | `3600` | no |
| permissions\_boundary\_arn | ARN of the IAM Permissions Boundary to attach to the IAM Role. | `string` | `"arn:aws:iam::xxxxxxxxxxxx:policy/OrgPermissionBoundary"` | no |
| role\_description | Description of the IAM role | `string` | `"IAM role for EC2 instances with SSM and CloudWatch access"` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_profile\_arn | ARN of the instance profile |
| instance\_profile\_id | ID of the instance profile |
| instance\_profile\_name | Name of the instance profile (use this for EC2/ASG) |
| instance\_profile\_unique\_id | Unique ID of the instance profile |
| role\_arn | ARN of the IAM role |
| role\_id | ID of the IAM role |
| role\_name | Name of the IAM role |
| role\_unique\_id | Unique ID of the IAM role |
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
