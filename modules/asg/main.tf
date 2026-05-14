# ============================================================================
# AUTO SCALING GROUP MODULE - main.tf
# ============================================================================
# This module creates and manages an Auto Scaling Group (ASG) with a Launch
# Template.
#
# What this module does:
# - automatically launches and terminates EC2 instances based on demand
# - maintains the desired number of healthy instances across multiple AZs
# - integrates with ALB for health checks and traffic distribution
# - provides automatic scaling based on CPU or ALB request metrics
# - monitors instance health and replaces unhealthy instances automatically
# ============================================================================

# ============================================================================
# DATA SOURCES - Retrieve Information from AWS
# ============================================================================

# Get latest Organization Golden Image (Amazon Linux 2023) if AMI ID not provided.
data "aws_ami" "amazon_linux_2023" {
  count       = var.ami_id == "" ? 1 : 0 # Only query if ami_id is empty
  most_recent = true                     # Get the latest version
  owners      = ["xxxxxxxxxxxx"]         # Organization AMI Team account
  # Replace xxxxxxxxxxxx with the AWS account ID that owns your Golden AMIs

  # Your Organization uses "Golden Images" - pre-hardened AMIs with:
  # - security patches applied
  # - corporate security standards
  # - pre-installed monitoring agents

  # Filter for Organization Golden Amazon Linux 2023 images.
  filter {
    name   = "name"
    values = ["org-golden-prod-al-2023*"] # Naming pattern for Golden Images
  }

  # Only use AMIs in "available" state.
  filter {
    name   = "state"
    values = ["available"]
  }

  # x86_64 architecture.
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  # HVM virtualization (Hardware Virtual Machine - full virtualization).
  # HVM provides better performance than paravirtualization (PV).
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get current AWS account ID for KMS grant creation.
data "aws_caller_identity" "current" {}

# Get current AWS region where resources are deployed.
data "aws_region" "current" {}

# ============================================================================
# KMS GRANT FOR AUTO SCALING SERVICE - AMI DECRYPTION
# ============================================================================
# Auto Scaling needs permission to decrypt the encrypted AMI snapshot.
# This grant provides the necessary KMS permissions to the Auto Scaling
# service.
#
# Why this is needed:
# - Organization Golden AMIs are encrypted with a shared KMS key
# - Auto Scaling service needs permission to decrypt the AMI to launch instances
# - without this grant, instance launches will fail with encryption errors
#
# Grant #1: AMI decryption (Organization Golden AMI shared key)
# - Key owner: AMI Team Account (xxxxxxxxxxxx)
# - Key: mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# - this grant is always created because it is required for all deployments
# ============================================================================

resource "null_resource" "kms_grant_ami_decryption" {
  # Triggers force recreation when these values change.
  triggers = {
    ami_kms_key = var.ami_kms_key_id                          # AMI encryption key
    account_id  = data.aws_caller_identity.current.account_id # Current AWS account
    region      = data.aws_region.current.name                # Current region
  }

  # Note: The provisioner commands are commented out but documented for
  # reference. In production, you would uncomment these to actually create the
  # KMS grant.

  # What this grant does:
  # 1. Identifies the grantee: Auto Scaling service role in your account
  # 2. Grants KMS operations: Decrypt, Encrypt, ReEncrypt, GenerateDataKey, etc.
  # 3. Applies to: Organization Golden AMI KMS key
  # 4. Scope: Only Auto Scaling service can use this grant

  # provisioner "local-exec" {
  #   command = <<-EOT
  #     aws kms create-grant \
  #       --region eu-west-1 \
  #       --key-id ${var.ami_kms_key_id} \
  #       --grantee-principal arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling \
  #       --operations "Encrypt" "Decrypt" "ReEncryptFrom" "ReEncryptTo" "GenerateDataKey" "GenerateDataKeyWithoutPlaintext" "DescribeKey" "CreateGrant" \
  #       2>&1 | grep -q "GrantId" || true
  #   EOT
  # }

  # Cleanup on destroy (AWS handles this automatically).
  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "echo 'KMS Grant cleanup handled by AWS'"
  # }
}

# ============================================================================
# KMS GRANT FOR AUTO SCALING SERVICE - CUSTOM EBS ENCRYPTION
# ============================================================================
# If you provide a custom KMS key for EBS encryption, Auto Scaling also needs
# permission to use that key when creating new encrypted volumes.
resource "null_resource" "kms_grant_ebs_encryption" {
  # Triggers force recreation when these values change.
  triggers = {
    ebs_kms_key = var.ebs_kms_key_id
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
  }

  # What this grant does:
  # 1. Allows Auto Scaling to encrypt new EBS volumes with your custom key
  # 2. Applies when instances are launched or volumes are created
  # 3. Only activated when ebs_kms_key_id is provided

  # provisioner "local-exec" {
  #   command = <<-EOT
  #     aws kms create-grant \
  #       --region ${data.aws_region.current.name} \
  #       --key-id ${var.ebs_kms_key_id} \
  #       --grantee-principal arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling \
  #       --operations "Encrypt" "Decrypt" "ReEncryptFrom" "ReEncryptTo" "GenerateDataKey" "GenerateDataKeyWithoutPlaintext" "DescribeKey" "CreateGrant" \
  #       2>&1 | grep -q "GrantId" || true
  #   EOT
  # }

  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "echo 'KMS Grant cleanup handled by AWS'"
  # }
}

# ============================================================================
# LAUNCH TEMPLATE - Define Instance Configuration
# ============================================================================
# Launch Template is a blueprint defining how EC2 instances should be
# configured. Think of it as a recipe that Auto Scaling uses to launch
# identical instances.
resource "aws_launch_template" "this" {
  name_prefix   = "${local.name}-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Why launch templates?
  # - versioning: track configuration changes over time
  # - consistency: all instances are launched with the same configuration
  # - updates: change template version to update the entire ASG

  # Network configuration.
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_ids
    delete_on_termination       = true
  }

  # IAM instance profile (permissions for instances to access AWS services).
  iam_instance_profile {
    name = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : null
  }

  # User data script (runs automatically on first boot).
  user_data = var.user_data_base64 != "" ? var.user_data_base64 : base64encode(var.user_data_script)

  # CloudWatch monitoring configuration.
  monitoring {
    enabled = var.detailed_monitoring
  }

  # EBS optimization (dedicated bandwidth for storage).
  ebs_optimized = var.ebs_optimized

  # Root volume configuration (primary disk).
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = var.ebs_kms_key_id != "" ? true : var.ebs_encryption_enabled
      kms_key_id            = var.ebs_kms_key_id != "" ? var.ebs_kms_key_id : null
    }
  }

  # Instance Metadata Service (IMDS) configuration.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # IMDSv2 (Instance Metadata Service v2) explained:
  # - IMDSv1: simple HTTP GET requests (vulnerable to SSRF attacks)
  # - IMDSv2: session-based (requires token, more secure)
  # - best practice: require_imdsv2 = true

  # Tags for EC2 instances launched from this template.
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name        = "${local.name}-instance"
        Environment = var.environment
        ManagedBy   = "terraform"
      }
    )
  }

  # Tags for EBS volumes attached to instances.
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name        = "${local.name}-volume"
        Environment = var.environment
        ManagedBy   = "terraform"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }

  # Tags for the Launch Template itself.
  tags = merge(
    var.tags,
    {
      Name        = "${local.name}-launch-template"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# ============================================================================
# AUTO SCALING GROUP - Manage Instance Lifecycle
# ============================================================================
# The ASG automatically maintains the desired number of healthy instances,
# launching new ones if instances fail or terminate.
resource "aws_autoscaling_group" "this" {
  name                = local.name
  vpc_zone_identifier = var.private_subnet_ids

  # Wait for KMS grants before launching instances to avoid encryption
  # permission errors.
  depends_on = [
    null_resource.kms_grant_ami_decryption,
    null_resource.kms_grant_ebs_encryption
  ]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Capacity example:
  # - min_size = 2: always keep 2 instances running
  # - max_size = 5: never exceed 5 instances
  # - desired_capacity = 3: try to maintain 3 instances

  launch_template {
    id      = aws_launch_template.this.id
    version = var.launch_template_version
  }

  # Template versions explained:
  # - $Latest: always use newest version (automatic updates)
  # - $Default: use default version (controlled updates)
  # - "1", "2", etc.: specific version (pinned configuration)

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  termination_policies      = var.termination_policies
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  wait_for_elb_capacity     = var.target_group_arns != null ? var.min_size : null

  # Load balancer integration.
  target_group_arns = var.target_group_arns

  # Metrics collection for CloudWatch monitoring.
  enabled_metrics = var.enabled_metrics

  # Instance refresh configuration for zero-downtime updates.
  dynamic "instance_refresh" {
    for_each = var.enable_instance_refresh ? [1] : []

    content {
      strategy = "Rolling"

      preferences {
        min_healthy_percentage = var.instance_refresh_min_healthy_percentage
        instance_warmup        = var.instance_refresh_instance_warmup
      }
    }
  }

  # Tags propagated to instances.
  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name        = local.name
        Environment = var.environment
        ManagedBy   = "terraform"
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# ============================================================================
# AUTO SCALING POLICIES - Automatic Capacity Adjustment
# ============================================================================
# Scaling policies automatically add or remove instances based on metrics.
# Target tracking is the simplest approach: set a target value, AWS handles the
# rest.

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  count = var.enable_cpu_target_tracking ? 1 : 0

  name                   = "${local.name}-cpu-tracking"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_tracking_target
  }
}

resource "aws_autoscaling_policy" "alb_target_tracking" {
  count = var.enable_alb_target_tracking && var.target_group_arns != null ? 1 : 0

  name                   = "${local.name}-alb-tracking"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.alb_target_tracking_resource_label
    }
    target_value = var.alb_target_tracking_target
  }
}

# ============================================================================
# CLOUDWATCH ALARMS - Monitoring and Alerting
# ============================================================================
# These alarms are for alerting only. Scaling itself is handled by target
# tracking policies above.

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-high-cpu"
  alarm_description   = "Triggers when ASG average CPU exceeds threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.high_cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  tags = merge(
    var.tags,
    {
      Name        = "${local.name}-high-cpu-alarm"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-low-cpu"
  alarm_description   = "Triggers when ASG average CPU is below threshold (cost optimization)"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.low_cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  tags = merge(
    var.tags,
    {
      Name        = "${local.name}-low-cpu-alarm"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
