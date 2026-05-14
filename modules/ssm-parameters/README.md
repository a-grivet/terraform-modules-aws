# Ssm-Parameters

> Terraform module that stores application and infrastructure configuration values in AWS Systems Manager Parameter Store.

---

## What it does

- creates SSM parameters for application configuration
- supports both `String` and `SecureString` parameters
- supports encryption through a customer-managed KMS key
- exposes parameter names and ARNs for downstream consumers

---

## Usage

```hcl
module "ssm_parameters" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/ssm-parameters?ref=v1.0.0"

  app_id      = "myappid"
  environment = "d"
  kms_key_id  = module.kms_ssm.key_id

  db_writer_endpoint = module.aurora.cluster_endpoint
  db_reader_endpoint = module.aurora.cluster_reader_endpoint
  db_port            = module.aurora.cluster_port
  db_name            = module.aurora.cluster_database_name
  db_username        = module.aurora.cluster_master_username
  db_secret_arn      = module.db_secret.secret_arn
}
```

---

## Parameter Path Format

SSM parameters follow a hierarchical path format aligned with the organization naming convention:

| Environment | Path format |
|---|---|
| Non-prod (`c`, `t`, `d`, `s`) | `/{app_id}/np/{env}/database/<parameter>` |
| Prod (`p`) | `/{app_id}/{env}/database/<parameter>` |

Examples:

```
/myappid/np/d/database/writer-endpoint   # dev
/myappid/np/s/database/writer-endpoint   # stage
/myappid/p/database/writer-endpoint      # prod
```

Use `parameter_path_prefix` to override the default path if needed.

---

## Notes

- this module is commonly used to publish database endpoints, usernames, ports, and secret references
- it is intended to be consumed by applications or operational tooling that read configuration from SSM

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
| [aws_ssm_parameter.db_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_reader_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_secret_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_writer_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| db\_name | Database name | `string` | n/a | yes |
| db\_port | Database port number | `number` | n/a | yes |
| db\_reader\_endpoint | Aurora cluster reader endpoint | `string` | n/a | yes |
| db\_secret\_arn | ARN of Secrets Manager secret containing database password | `string` | n/a | yes |
| db\_username | Database master username | `string` | n/a | yes |
| db\_writer\_endpoint | Aurora cluster writer endpoint | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| kms\_key\_id | KMS key ID for encrypting SecureString parameters | `string` | n/a | yes |
| parameter\_path\_prefix | Custom parameter path prefix (optional, overrides default) | `string` | `null` | no |
| tags | Tags to apply to all SSM parameters | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| database\_name\_parameter\_name | Database name parameter name |
| parameter\_arns | Map of all SSM parameter ARNs (for IAM policies) |
| parameter\_names | Map of all SSM parameter names (paths) |
| parameter\_path\_prefix | Parameter path prefix used for all parameters |
| path\_prefix | Parameter path prefix (alias for parameter\_path\_prefix) |
| port\_parameter\_name | Port parameter name |
| reader\_endpoint\_parameter\_name | Reader endpoint parameter name |
| secret\_arn\_parameter\_name | Secret ARN parameter name |
| username\_parameter\_name | Username parameter name |
| writer\_endpoint\_parameter\_name | Writer endpoint parameter name |
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
