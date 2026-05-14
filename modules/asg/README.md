# Auto Scaling Group

> Terraform module that creates an Auto Scaling Group, launch template, and related scaling resources for EC2-based workloads.

---

## What it does

- creates a launch template for EC2 instances
- creates an Auto Scaling Group across the requested subnets
- supports target group attachment for ALB integration
- optionally configures scaling policies and CloudWatch alarms
- supports KMS grant helper resources when encrypted AMIs or EBS volumes are used

---

## Usage

```hcl
module "asg" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/asg?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
  subnet_ids   = ["subnet-aaa", "subnet-bbb"]
  vpc_id       = "vpc-0123456789abcdef0"
}
```

---

## Notes

- this module is intended for EC2-backed blueprint patterns rather than container services
- consumers usually combine it with `alb`, `iam`, `kms`, and `monitoring`

---

<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7.4 |
| aws | >= 5.0 |
| null | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| null | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.alb_target_tracking](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.cpu_target_tracking](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_metric_alarm.high_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.low_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [null_resource.kms_grant_ami_decryption](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.kms_grant_ebs_encryption](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| private\_subnet\_ids | List of private subnet IDs where ASG instances will be deployed | `list(string)` | n/a | yes |
| security\_group\_ids | List of security group IDs to attach to instances | `list(string)` | n/a | yes |
| alb\_target\_tracking\_resource\_label | Resource label for ALB target tracking (format: app/load-balancer-name/id/targetgroup/target-group-name/id) | `string` | `""` | no |
| alb\_target\_tracking\_target | Target number of requests per target for ALB-based scaling | `number` | `1000` | no |
| ami\_id | AMI ID to use for instances (defaults to latest Amazon Linux 2023 if empty) | `string` | `""` | no |
| ami\_kms\_key\_id | KMS key ID/ARN used to encrypt the AMI. Required for Auto Scaling to decrypt the AMI snapshot. Default is Organization Golden AMI shared key. | `string` | `"arn:aws:kms:eu-west-1:xxxxxxxxxxxx:key/mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"` | no |
| cpu\_target\_tracking\_target | Target CPU utilization percentage for target tracking | `number` | `70` | no |
| desired\_capacity | Desired number of instances in the ASG | `number` | `2` | no |
| detailed\_monitoring | Enable detailed CloudWatch monitoring (additional cost) | `bool` | `false` | no |
| ebs\_encryption\_enabled | Enable EBS encryption for volumes when no custom KMS key is provided | `bool` | `true` | no |
| ebs\_kms\_key\_id | KMS key ID/ARN for EBS volume encryption. If provided, a KMS Grant will be automatically created for Auto Scaling service | `string` | `""` | no |
| ebs\_optimized | Enable EBS optimization | `bool` | `true` | no |
| enable\_alb\_target\_tracking | Enable ALB request count target tracking scaling policy | `bool` | `false` | no |
| enable\_cloudwatch\_alarms | Enable CloudWatch alarms for ASG monitoring | `bool` | `true` | no |
| enable\_cpu\_target\_tracking | Enable CPU-based target tracking scaling policy | `bool` | `true` | no |
| enable\_instance\_refresh | Enable instance refresh for rolling updates | `bool` | `true` | no |
| enabled\_metrics | List of metrics to enable for ASG | `list(string)` | <pre>[<br/>  "GroupMinSize",<br/>  "GroupMaxSize",<br/>  "GroupDesiredCapacity",<br/>  "GroupInServiceInstances",<br/>  "GroupTotalInstances"<br/>]</pre> | no |
| health\_check\_grace\_period | Time (in seconds) after instance launch before health checks start | `number` | `300` | no |
| health\_check\_type | Health check type: EC2 or ELB | `string` | `"EC2"` | no |
| high\_cpu\_threshold | CPU threshold (%) to trigger high CPU alarm | `number` | `80` | no |
| iam\_instance\_profile\_name | IAM instance profile name to attach to instances | `string` | `""` | no |
| instance\_refresh\_instance\_warmup | Number of seconds until a newly launched instance is configured and ready to use | `number` | `300` | no |
| instance\_refresh\_min\_healthy\_percentage | Minimum healthy percentage during instance refresh | `number` | `90` | no |
| instance\_type | EC2 instance type | `string` | `"t3.micro"` | no |
| key\_name | EC2 key pair name for SSH access (leave empty for no SSH key) | `string` | `""` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| launch\_template\_version | Launch template version to use ($Latest, $Default, or version number) | `string` | `"$Latest"` | no |
| low\_cpu\_threshold | CPU threshold (%) to trigger low CPU alarm (cost optimization) | `number` | `20` | no |
| max\_size | Maximum number of instances in the ASG | `number` | `3` | no |
| min\_size | Minimum number of instances in the ASG | `number` | `1` | no |
| require\_imdsv2 | Require IMDSv2 for instance metadata (recommended for security) | `bool` | `true` | no |
| root\_volume\_size | Size of root volume in GB | `number` | `20` | no |
| root\_volume\_type | Type of root volume (gp3, gp2, io1, io2) | `string` | `"gp3"` | no |
| sns\_topic\_arn | SNS topic ARN for CloudWatch alarm notifications | `string` | `""` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| target\_group\_arns | List of target group ARNs to attach to ASG (for ALB/NLB integration) | `list(string)` | `null` | no |
| termination\_policies | List of termination policies for ASG | `list(string)` | <pre>[<br/>  "Default"<br/>]</pre> | no |
| user\_data\_base64 | User data script to run on instance launch (base64 encoded). Takes precedence over user\_data\_script if provided. | `string` | `""` | no |
| user\_data\_script | User data script to run on instance launch (plain text) | `string` | `""` | no |
| wait\_for\_capacity\_timeout | Maximum time to wait for ASG capacity (0 = no wait) | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_scaling\_policy\_arn | ARN of the ALB target tracking scaling policy |
| asg\_name | Name of the Auto Scaling Group (alias for autoscaling\_group\_name) |
| autoscaling\_group\_arn | ARN of the Auto Scaling Group |
| autoscaling\_group\_availability\_zones | Availability zones used by the Auto Scaling Group |
| autoscaling\_group\_desired\_capacity | Desired capacity of the Auto Scaling Group |
| autoscaling\_group\_id | ID of the Auto Scaling Group |
| autoscaling\_group\_max\_size | Maximum size of the Auto Scaling Group |
| autoscaling\_group\_min\_size | Minimum size of the Auto Scaling Group |
| autoscaling\_group\_name | Name of the Auto Scaling Group |
| cpu\_scaling\_policy\_arn | ARN of the CPU target tracking scaling policy |
| high\_cpu\_alarm\_arn | ARN of the high CPU CloudWatch alarm |
| launch\_template\_arn | ARN of the Launch Template |
| launch\_template\_id | ID of the Launch Template |
| launch\_template\_latest\_version | Latest version of the Launch Template |
| low\_cpu\_alarm\_arn | ARN of the low CPU CloudWatch alarm |
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
