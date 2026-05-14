# Acm-Alb

> Terraform module that creates an ACM certificate for ALB-based HTTPS endpoints and validates it through Route53 DNS records.

---

## What it does

- requests an ACM certificate for a single primary domain
- creates Route53 DNS validation records
- waits for ACM validation to complete
- optionally creates a CloudWatch alarm for certificate expiry

---

## Usage

```hcl
module "acm_alb" {
  source = "git::https://github.com/your-org/terraform-modules.git//modules/acm-alb?ref=v0.1.0"

  domain_name = "app.example.com"
  zone_id     = "Z0123456789ABCDE"
  environment = "dev"
  CostCenter  = "my-team"

  tags = {
    Project = "shared-platform"
  }
}
```

---

## Notes

- this module is intended for regional ACM usage, for example behind an ALB
- for CloudFront, use a dedicated module because the certificate must be created in `us-east-1`
- either `zone_id` or `zone_name` must be provided

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
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudwatch_metric_alarm.certificate_expiry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_route53_record.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| CostCenter | Cost center name for tracking costs | `string` | n/a | yes |
| domain\_name | Primary domain name for the certificate (e.g., app.example.com) | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| zone\_name | Route53 hosted zone name for DNS validation (e.g., example.com) | `string` | n/a | yes |
| acm\_sns\_topic\_arn | SNS topic ARN for certificate expiry notifications | `string` | `""` | no |
| enable\_expiry\_alarm | Enable CloudWatch alarm for certificate expiry (useful for imported certificates) | `bool` | `false` | no |
| expiry\_alarm\_threshold\_days | Number of days before expiry to trigger alarm | `number` | `30` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| validation\_timeout | Timeout for certificate validation | `string` | `"45m"` | no |
| zone\_id | Route53 Hosted Zone ID (optional, use instead of zone\_name for delegated zones) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate\_arn | ARN of the ACM certificate (use this for ALB/CloudFront) |
| certificate\_domain\_name | Domain name of the certificate |
| certificate\_id | ID of the ACM certificate |
| certificate\_not\_after | Expiration date of the certificate |
| certificate\_not\_before | Start date of the certificate validity period |
| certificate\_status | Status of the certificate (should be ISSUED after validation) |
| domain\_validation\_options | Domain validation options for the certificate |
| route53\_zone\_id | Route53 hosted zone ID used for DNS validation |
| validation\_record\_fqdns | List of FQDNs of DNS validation records |
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
