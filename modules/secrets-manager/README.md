# Secrets-Manager

> Terraform module that creates AWS Secrets Manager secrets and optionally generates secret values.

---

## What it does

- creates a Secrets Manager secret
- optionally generates a random secret value
- stores the generated or provided value as the current secret version
- exposes secret identifiers for downstream modules and application configuration

---

## Usage

```hcl
module "db_secret" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/secrets-manager?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
  secret_name  = "database-password"
}
```

---

## Notes

- this module is frequently used for database credentials and other application secrets
- when secret generation is enabled, the random provider is used intentionally to create the initial value

---

<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7.4 |
| aws | >= 5.0 |
| random | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| random | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.master_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| secret\_name | Name suffix for the secret (e.g., 'db-password', 'api-key') | `string` | n/a | yes |
| create\_random\_password | Generate random password (true) or use provided value (false) | `bool` | `true` | no |
| description | Description of the secret | `string` | `"Secret managed by Terraform"` | no |
| enable\_rotation | Enable automatic secret rotation | `bool` | `false` | no |
| kms\_key\_id | KMS key ID for encrypting the secret (leave empty for default) | `string` | `""` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| password\_length | Length of generated password | `number` | `32` | no |
| recovery\_window\_in\_days | Days to retain secret before permanent deletion (0 for immediate) | `number` | `7` | no |
| rotation\_days | Number of days between automatic rotations | `number` | `30` | no |
| rotation\_lambda\_arn | ARN of Lambda function for secret rotation | `string` | `""` | no |
| secret\_value | Secret value to store (required if create\_random\_password is false) | `string` | `""` | no |
| tags | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| random\_password | The generated random password (if create\_random\_password is true) |
| secret\_arn | ARN of the secret |
| secret\_id | ID of the secret |
| secret\_name | Name of the secret |
| secret\_value | The secret value (password) |
| secret\_version\_id | Version ID of the secret |
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
