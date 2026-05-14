# Application Load Balancer

> Terraform module that creates an Application Load Balancer with its listeners, target group, and optional CloudWatch alarms.

---

## What it does

- creates an internet-facing or internal ALB
- creates HTTP and optional HTTPS listeners
- creates a primary target group for application traffic
- supports optional path-based routing rules
- optionally creates baseline CloudWatch alarms for ALB health and latency

---

## Usage

```hcl
module "alb" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/alb?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
  vpc_id       = "vpc-0123456789abcdef0"
  subnet_ids   = ["subnet-aaa", "subnet-bbb"]
  alb_sg_id    = "sg-0123456789abcdef0"
}
```

---

## Notes

- this module is intended to be the shared ALB contract across multiple blueprints
- consumers typically wire its outputs into ASG, ECS, Route53, and monitoring modules

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
| [aws_cloudwatch_metric_alarm.high_response_time](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.http_5xx_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.unhealthy_targets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.path_based](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| security\_group\_ids | List of security group IDs to attach to the ALB | `list(string)` | n/a | yes |
| subnet\_ids | List of subnet IDs where ALB will be deployed (minimum 2 for HA) | `list(string)` | n/a | yes |
| vpc\_id | ID of the VPC where the ALB will be deployed | `string` | n/a | yes |
| access\_logs\_bucket | S3 bucket name for ALB access logs (required if enable\_access\_logs is true) | `string` | `""` | no |
| access\_logs\_prefix | S3 bucket prefix for ALB access logs | `string` | `"alb-logs"` | no |
| certificate\_arn | ARN of the SSL certificate to attach to the HTTPS listener (leave empty for HTTP only) | `string` | `""` | no |
| deregistration\_delay | Time in seconds to wait for in-flight requests to complete before deregistering a target | `number` | `300` | no |
| drop\_invalid\_header\_fields | Drop invalid HTTP header fields (security best practice) | `bool` | `true` | no |
| enable\_access\_logs | Enable ALB access logs to S3 | `bool` | `false` | no |
| enable\_cloudwatch\_alarms | Enable CloudWatch alarms for ALB monitoring | `bool` | `true` | no |
| enable\_cross\_zone\_load\_balancing | Enable cross-zone load balancing | `bool` | `true` | no |
| enable\_deletion\_protection | Enable deletion protection for the ALB (recommended for production) | `bool` | `false` | no |
| enable\_http2 | Enable HTTP/2 protocol | `bool` | `true` | no |
| enable\_stickiness | Enable session stickiness (session affinity) | `bool` | `false` | no |
| health\_check\_enabled | Enable health checks | `bool` | `true` | no |
| health\_check\_healthy\_threshold | Number of consecutive health check successes required before considering a target healthy | `number` | `3` | no |
| health\_check\_interval | Time in seconds between health checks | `number` | `30` | no |
| health\_check\_matcher | HTTP status codes to use when checking for a successful response from a target | `string` | `"200"` | no |
| health\_check\_path | Path for health check requests | `string` | `"/health"` | no |
| health\_check\_protocol | Protocol for health checks (HTTP or HTTPS) | `string` | `"HTTP"` | no |
| health\_check\_timeout | Time in seconds to wait for a health check response | `number` | `5` | no |
| health\_check\_unhealthy\_threshold | Number of consecutive health check failures required before considering a target unhealthy | `number` | `3` | no |
| http\_5xx\_alarm\_threshold | Number of 5xx errors to trigger alarm | `number` | `10` | no |
| idle\_timeout | Time in seconds that the connection is allowed to be idle | `number` | `60` | no |
| internal | Whether the load balancer is internal (true) or internet-facing (false) | `bool` | `false` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| path\_based\_routing\_rules | List of path-based routing rules for the listener | <pre>list(object({<br/>    priority      = number       # Rule priority<br/>    path_patterns = list(string) # URL paths to match (e.g., ["/api/*", "/v1/*"])<br/>  }))</pre> | `[]` | no |
| response\_time\_alarm\_threshold | Response time in seconds to trigger alarm | `number` | `5` | no |
| sns\_topic\_arn | SNS topic ARN for CloudWatch alarm notifications | `string` | `""` | no |
| ssl\_policy | SSL policy for HTTPS listener (only used if certificate\_arn is provided) | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| stickiness\_cookie\_duration | Time period in seconds during which requests should be routed to the same target | `number` | `86400` | no |
| stickiness\_type | Type of stickiness (lb\_cookie for ALB-generated cookies, app\_cookie for application cookies) | `string` | `"lb_cookie"` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| target\_group\_port | Port on which targets receive traffic | `number` | `80` | no |
| target\_group\_protocol | Protocol to use for routing traffic to targets (HTTP or HTTPS) | `string` | `"HTTP"` | no |
| target\_type | Type of target (instance, ip, or lambda) | `string` | `"instance"` | no |
| unhealthy\_target\_alarm\_threshold | Number of unhealthy targets to trigger alarm | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_arn | ARN of the Application Load Balancer |
| alb\_arn\_suffix | ARN suffix of the Application Load Balancer (for CloudWatch metrics) |
| alb\_dns\_name | DNS name of the Application Load Balancer |
| alb\_id | ID of the Application Load Balancer |
| alb\_url | URL to access the Application Load Balancer |
| alb\_zone\_id | Zone ID of the Application Load Balancer (for Route53 alias records) |
| high\_response\_time\_alarm\_arn | ARN of the high response time CloudWatch alarm |
| http\_5xx\_errors\_alarm\_arn | ARN of the 5xx errors CloudWatch alarm |
| http\_listener\_arn | ARN of the HTTP listener |
| https\_listener\_arn | ARN of the HTTPS listener |
| target\_group\_arn | ARN of the primary target group (use this for ASG attachment) |
| target\_group\_arn\_suffix | ARN suffix of the primary target group (for CloudWatch metrics) |
| target\_group\_id | ID of the primary target group |
| target\_group\_name | Name of the primary target group |
| unhealthy\_targets\_alarm\_arn | ARN of the unhealthy targets CloudWatch alarm |
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
