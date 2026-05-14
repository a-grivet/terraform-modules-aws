# Kms

> Terraform module that creates a customer-managed KMS key and alias for shared encryption use cases across multiple blueprints.

---

## What it does

- creates a KMS key with configurable deletion window and rotation
- creates a readable alias using `project_name`, `environment`, and `key_name`
- supports IAM administrators and IAM key users
- optionally allows CloudWatch Logs to use the key
- optionally allows selected AWS service principals such as CloudFront to use the key

---

## Usage

```hcl
module "kms" {
  source = "git::https://github.com/your-org/terraform-modules.git//modules/kms?ref=v0.1.0"

  project_name = "shared-platform"
  environment  = "dev"
  key_name     = "s3-origin"
  description  = "KMS key for static website S3 origin encryption"

  service_principals = ["cloudfront.amazonaws.com"]

  tags = {
    Project = "shared-platform"
  }
}
```

---

## Notes

- this module is intended as the shared KMS contract for `basic-iaas`, `ecs-standalone`, and `static-website-content`
- outputs are generic on purpose so the same module can be reused across multiple encryption use cases

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
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| description | Description of the KMS key | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| key\_name | Name suffix for the KMS key (for example ebs, rds, secrets, s3-origin) | `string` | n/a | yes |
| allow\_cloudwatch\_logs | Allow CloudWatch Logs to use this key | `bool` | `false` | no |
| deletion\_window\_in\_days | Duration in days before key deletion (7-30 days) | `number` | `30` | no |
| enable\_key\_rotation | Enable automatic key rotation | `bool` | `true` | no |
| key\_administrators | List of IAM ARNs that can administer the key | `list(string)` | `[]` | no |
| key\_users | List of IAM ARNs that can use the key (encrypt/decrypt) | `list(string)` | `[]` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| multi\_region | Enable multi-region key | `bool` | `false` | no |
| service\_principals | List of AWS service principals allowed to use the key (for example cloudfront.amazonaws.com) | `list(string)` | `[]` | no |
| tags | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| key\_alias\_arn | ARN of the KMS key alias |
| key\_alias\_name | Alias name of the KMS key |
| key\_arn | ARN of the KMS key |
| key\_id | ID of the KMS key |
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
