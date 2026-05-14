# S3-origin

> Terraform module that creates the private S3 origin bucket used behind CloudFront distributions.

---

## What it does

- creates the S3 bucket used as a CloudFront origin
- configures encryption, versioning, and public access protection
- applies the bucket policy required for secure CloudFront access
- supports lifecycle configuration for origin content management

---

## Usage

```hcl
module "s3_origin" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/s3-origin?ref=v1.0.0"

  project_name = "static-site"
  environment  = "dev"
}
```

---

## Notes

- this module is intended for private S3 origins fronted by CloudFront, not public website hosting
- consumers usually combine it with `cloudfront`, `kms`, and `logs`

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
| [aws_s3_bucket.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| cloudfront\_distribution\_arn | ARN of the CloudFront distribution allowed to access the origin | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| kms\_key\_arn | ARN of the KMS key used to encrypt bucket objects | `string` | n/a | yes |
| abort\_incomplete\_multipart\_upload\_days | Number of days after which incomplete multipart uploads are deleted | `number` | `7` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| noncurrent\_version\_expiration\_days | Number of days to retain old object versions before deletion | `number` | `30` | no |
| tags | Common tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn | ARN of the S3 origin bucket |
| bucket\_id | ID of the S3 origin bucket |
| bucket\_regional\_domain\_name | Regional domain name of the S3 bucket |
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
