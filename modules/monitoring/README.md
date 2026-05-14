# Monitoring

> Reusable CloudWatch monitoring foundation for your blueprint repositories.

The module deliberately owns only the common monitoring infrastructure:

- SNS topic for alarm notifications
- optional email subscription
- CloudWatch dashboard creation
- CloudWatch alarm creation from generic HCL definitions

The consuming blueprint remains responsible for its own observability model:

- which dashboard widgets it wants
- which metrics it wants to alarm on
- which thresholds make sense for its workload

That split keeps the module reusable across very different architectures without
hard-coding `basic-iaas`, `ecs`, or `static-website` logic into the shared layer.

---

## How To Use It

The recommended pattern in a blueprint is:

1. store the dashboard structure in a local JSON template file
2. render that template with `templatefile(...)`
3. define alarms in HCL with a local map
4. pass both into the centralized `monitoring` module

---

## Recommended Blueprint Structure

```text
infrastructure/
  environments/
    dev/
      main.tf
  monitoring/
    dashboard.json.tftpl
    alarms.tf
```

---

## Example Module Call

```hcl
module "monitoring" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/monitoring?ref=v1.0.0"

  project_name   = var.project_name
  environment    = var.environment
  alert_email    = var.alert_email
  sns_kms_key_id = module.kms.key_id
  tags           = var.tags

  dashboard_body = templatefile("${path.module}/../../monitoring/dashboard.json.tftpl", {
    region                  = var.aws_region
    alb_arn_suffix          = module.alb.alb_arn_suffix
    target_group_arn_suffix = module.alb.target_group_arn_suffix
    ecs_cluster_name        = module.ecs.cluster_name
    ecs_service_name        = module.ecs.service_name
    db_cluster_id           = module.aurora.cluster_id
  })

  alarm_definitions = local.monitoring_alarms
}
```

---

## Configuring Dashboard Metrics

The dashboard is expected to come from a JSON template stored in the consumer
repository.

Example `dashboard.json.tftpl`:

```json
{
  "widgets": [
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "properties": {
        "title": "ALB Request Count",
        "region": "${region}",
        "stat": "Sum",
        "period": 300,
        "metrics": [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${alb_arn_suffix}"]
        ]
      }
    }
  ]
}
```

Why this pattern works well:

- the dashboard remains close to the blueprint that owns the architecture
- JSON stays compatible with CloudWatch native dashboard format
- Terraform still injects dynamic identifiers such as ARNs, cluster names, or distribution IDs

---

## Configuring Alarm Metrics

Alarms are best expressed in HCL rather than JSON so they stay easy to review,
typed, and directly connected to Terraform outputs.

Example `locals` block in a blueprint:

```hcl
locals {
  monitoring_alarms = {
    alb_unhealthy_targets = {
      alarm_description   = "CRITICAL: Unhealthy targets detected"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "UnHealthyHostCount"
      namespace           = "AWS/ApplicationELB"
      period              = 300
      statistic           = "Average"
      threshold           = 1
      treat_missing_data  = "notBreaching"
      dimensions = {
        LoadBalancer = module.alb.alb_arn_suffix
        TargetGroup  = module.alb.target_group_arn_suffix
      }
      tags = {
        Severity = "CRITICAL"
      }
    }
  }
}
```

### Metric Query Alarms

The module also supports alarms based on `metric_query`, which is useful for
CloudWatch math expressions.

Example:

```hcl
locals {
  monitoring_alarms = {
    traffic_spike = {
      alarm_description   = "Traffic spike detected"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      threshold           = 200
      treat_missing_data  = "notBreaching"

      metric_queries = [
        {
          id          = "e1"
          expression  = "(m1 / m2) * 100"
          label       = "Traffic Increase Percentage"
          return_data = true
        },
        {
          id = "m1"
          metric = {
            metric_name = "Requests"
            namespace   = "AWS/CloudFront"
            period      = 300
            stat        = "Sum"
            dimensions = {
              DistributionId = module.cloudfront.distribution_id
            }
          }
        },
        {
          id = "m2"
          metric = {
            metric_name = "Requests"
            namespace   = "AWS/CloudFront"
            period      = 300
            stat        = "Sum"
            dimensions = {
              DistributionId = module.cloudfront.distribution_id
            }
          }
          return_data = false
        }
      ]

      tags = {
        Severity = "WARNING"
      }
    }
  }
}
```

---

## Usage Notes

- Alarm keys are normalized to lower-case inside the module so outputs remain stable
- If `alarm_actions` or `ok_actions` are not explicitly provided, the module routes state changes to the shared SNS topic by default
- `dashboard_body` must be valid JSON when `create_dashboard = true`
- The SNS email subscription still requires manual confirmation in AWS

---

## Suggested Consumer Convention

To keep implementations easy to scan across repositories, a good convention is:

- keep dashboard templates in `infrastructure/monitoring/dashboard.json.tftpl`
- keep alarms in a dedicated `locals` block such as `infrastructure/monitoring/alarms.tf`
- keep threshold values in environment variables or Terraform variables, not hard-coded in many places

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
| [aws_cloudwatch_dashboard.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sns_topic.alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| alarm\_definitions | Map of CloudWatch alarm definitions. Keys are normalized to lower-case inside the module for stable outputs | <pre>map(object({<br/>    alarm_name                = optional(string)<br/>    alarm_description         = optional(string)<br/>    comparison_operator       = string<br/>    evaluation_periods        = number<br/>    threshold                 = number<br/>    datapoints_to_alarm       = optional(number)<br/>    treat_missing_data        = optional(string)<br/>    actions_enabled           = optional(bool)<br/>    alarm_actions             = optional(list(string))<br/>    ok_actions                = optional(list(string))<br/>    insufficient_data_actions = optional(list(string))<br/>    metric_name               = optional(string)<br/>    namespace                 = optional(string)<br/>    period                    = optional(number)<br/>    statistic                 = optional(string)<br/>    extended_statistic        = optional(string)<br/>    unit                      = optional(string)<br/>    dimensions                = optional(map(string))<br/>    tags                      = optional(map(string))<br/>    metric_queries = optional(list(object({<br/>      id          = string<br/>      expression  = optional(string)<br/>      label       = optional(string)<br/>      return_data = optional(bool)<br/>      account_id  = optional(string)<br/>      metric = optional(object({<br/>        metric_name = string<br/>        namespace   = string<br/>        period      = number<br/>        stat        = string<br/>        unit        = optional(string)<br/>        dimensions  = optional(map(string))<br/>      }))<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| alert\_email | Email address to receive alarm notifications | `string` | `""` | no |
| create\_dashboard | Create a CloudWatch dashboard from dashboard\_body | `bool` | `true` | no |
| dashboard\_body | Rendered CloudWatch dashboard JSON body. Typically produced by templatefile() from the consuming blueprint | `string` | `null` | no |
| dashboard\_name\_override | Optional custom dashboard name. When unset, the standard project-environment name is used | `string` | `null` | no |
| enable\_alarms | Enable CloudWatch alarm creation | `bool` | `true` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| sns\_kms\_key\_id | KMS key ID used to encrypt the SNS topic (optional) | `string` | `null` | no |
| sns\_topic\_name\_override | Optional custom SNS topic name. When unset, the standard project-environment name is used | `string` | `null` | no |
| tags | Common tags applied to all monitoring resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alarm\_arns | Map of CloudWatch alarm ARNs keyed by normalized alarm identifier |
| alarm\_names | Map of CloudWatch alarm names keyed by normalized alarm identifier |
| dashboard\_arn | ARN of the CloudWatch dashboard, when dashboard creation is enabled |
| dashboard\_name | Name of the CloudWatch dashboard, when dashboard creation is enabled |
| dashboard\_url | URL to open the CloudWatch dashboard in the AWS Console, when dashboard creation is enabled |
| monitoring\_summary | High-level summary of the monitoring configuration |
| sns\_topic\_arn | ARN of the SNS topic used for alert notifications |
| sns\_topic\_name | Name of the SNS topic used for alert notifications |
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
