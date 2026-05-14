# Acm-Cloudfront

> Terraform module that creates an ACM certificate for CloudFront in `us-east-1` and validates it through Route53 DNS records.

---

## Usage

```hcl
module "acm" {
  source = "git::https://github.com/your-org/terraform-modules.git//modules/acm-cloudfront?ref=v0.1.0"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  project_name              = "static-website"
  environment               = "dev"
  domain_name               = "www.example.com"
  subject_alternative_names = []
  zone_id                   = "Z0123456789ABCDE"
  tags                      = {}
}
```

---

## Notes

- this module is intended for CloudFront certificates only
- ACM certificates used by CloudFront must be created in `us-east-1`
- the caller must pass the aliased provider `aws.us_east_1`

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
| aws.us\_east\_1 | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| domain\_name | Primary domain name for the certificate | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| zone\_id | Route 53 hosted zone ID for DNS validation | `string` | n/a | yes |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| subject\_alternative\_names | Additional domain names for the certificate | `list(string)` | `[]` | no |
| tags | Common tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate\_arn | ARN of the ACM certificate |
| certificate\_domain | Domain name of the certificate |
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
