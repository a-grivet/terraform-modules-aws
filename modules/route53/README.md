# Route53

> Terraform module that creates Route53 DNS records used by the blueprint repositories.

---

## What it does

- creates DNS records in an existing hosted zone
- supports integration with ALB or CloudFront outputs
- supports alias records for AWS-managed endpoints
- exposes record information for downstream references

---

## Usage

```hcl
module "route53" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/route53?ref=v1.0.0"

  zone_id      = "Z0123456789ABCDE"
  record_name  = "app.example.com"
  target_dns   = "my-alb-123.eu-west-1.elb.amazonaws.com"
  target_zone_id = "Z32O12XQLNTSW2"
}
```

---

## Notes

- this module is intentionally focused on DNS record creation, not hosted zone management
- consumers usually pair it with `alb` or `cloudfront` depending on the architecture

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
| [aws_route53_record.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.website_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudfront\_domain\_name | CloudFront distribution domain name | `string` | n/a | yes |
| domain\_name | Domain name for the website | `string` | n/a | yes |
| zone\_id | Route 53 hosted zone ID | `string` | n/a | yes |
| cloudfront\_zone\_id | CloudFront hosted zone ID (always Z2FDTNDATAQYW2) | `string` | `"Z2FDTNDATAQYW2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| fqdn | Fully qualified domain name |
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
