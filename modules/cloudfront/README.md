# Cloudfront

> Terraform module that creates a CloudFront distribution and the supporting resources commonly needed for S3-backed websites.

---

## What it does

- creates a CloudFront distribution
- creates an Origin Access Control for secure S3 origins
- creates a response headers policy for common security headers
- supports custom domains and ACM certificate integration
- exposes distribution identifiers used by Route53 and monitoring

---

## Usage

```hcl
module "cloudfront" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/cloudfront?ref=v1.0.0"

  project_name = "static-site"
  environment  = "dev"
  domain_name  = "www.example.com"
}
```

---

## Notes

- this module is intended for CloudFront-based website or CDN patterns
- consumers usually pair it with `acm-cloudfront`, `s3-origin`, `route53`, `logs`, and `monitoring`

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
| [aws_cloudfront_distribution.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.s3_oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_response_headers_policy.security_headers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acm\_certificate\_arn | ARN of the ACM certificate used for HTTPS | `string` | n/a | yes |
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| domain\_name | Custom domain name for the CloudFront distribution | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| logs\_bucket\_domain\_name | Domain name of the S3 bucket receiving CloudFront logs | `string` | n/a | yes |
| s3\_bucket\_id | ID of the S3 origin bucket | `string` | n/a | yes |
| s3\_bucket\_regional\_domain\_name | Regional domain name of the S3 origin bucket | `string` | n/a | yes |
| default\_root\_object | Default file to serve, typically index.html | `string` | `"index.html"` | no |
| default\_ttl | Default cache time to live in seconds | `number` | `3600` | no |
| error\_403\_response\_code | HTTP response code returned for 403 errors | `number` | `200` | no |
| error\_403\_response\_path | Path returned to users for 403 errors | `string` | `"/index.html"` | no |
| error\_404\_response\_code | HTTP response code returned for 404 errors | `number` | `200` | no |
| error\_404\_response\_path | Path returned to users for 404 errors | `string` | `"/index.html"` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| log\_prefix | Prefix for CloudFront log files written to S3 | `string` | `"cloudfront/"` | no |
| max\_ttl | Maximum cache time to live in seconds | `number` | `86400` | no |
| min\_ttl | Minimum cache time to live in seconds | `number` | `0` | no |
| minimum\_protocol\_version | Minimum TLS version accepted for viewer HTTPS connections | `string` | `"TLSv1.2_2021"` | no |
| price\_class | CloudFront price class | `string` | `"PriceClass_100"` | no |
| tags | Common tags applied to CloudFront resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| distribution\_arn | ARN of the CloudFront distribution |
| distribution\_domain\_name | Domain name of the CloudFront distribution |
| distribution\_id | ID of the CloudFront distribution |
| oac\_id | ID of the Origin Access Control |
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
