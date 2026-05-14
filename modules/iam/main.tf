# ============================================================================
# IAM ROLE MODULE FOR EC2 INSTANCES - main.tf
# ============================================================================
# This module creates an IAM role and instance profile for EC2 instances.
#
# What is IAM (Identity and Access Management)?
# - IAM controls WHO can do WHAT in AWS
# - IAM Roles: Temporary credentials for AWS services (EC2, Lambda, etc.)
# - IAM Policies: JSON documents defining permissions (read S3, write CloudWatch, etc.)
#
# Why EC2 instances need IAM roles:
# - Access AWS services securely (no hardcoded credentials)
# - CloudWatch: Send logs and metrics
# - SSM: Remote access via Session Manager (no SSH keys needed)
# - S3: Read/write files
# - Secrets Manager: Retrieve passwords and API keys
# - Parameter Store: Retrieve configuration
#
# Architecture:
# - IAM Role: Trust policy (who can assume) + permissions policies (what they can do)
# - Instance Profile: Wrapper that attaches role to EC2 instance
# - Managed Policies: Pre-built AWS policies (SSM, CloudWatch)
# - Custom Policies: Organization-specific permissions
#
# Key Security Features:
# - Permissions Boundary: Hard limit on maximum permissions
# - Principle of Least Privilege: Grant only necessary permissions
# - No credentials in code: IAM role provides temporary credentials automatically
# ============================================================================

# ============================================================================
# IAM ROLE - Define Trust and Permissions
# ============================================================================
# IAM Role defines:
# 1. WHO can assume this role (Trust Policy)
# 2. WHAT permissions they have (Permissions Policies)

resource "aws_iam_role" "this" {
  name_prefix = local.name_prefix    # Role name prefix
  description = var.role_description # Human-readable description

  # ===== TRUST POLICY (AssumeRole Policy) =====
  # Defines WHO can assume this role (which service/principal)
  assume_role_policy = jsonencode({
    Version = "2012-10-17" # IAM policy language version (always use this)
    Statement = [
      {
        Action = "sts:AssumeRole" # STS = Security Token Service (temporary credentials)
        Effect = "Allow"          # Allow or Deny
        Principal = {
          Service = "ec2.amazonaws.com" # Only EC2 service can assume this role
        }
      }
    ]
  })

  # ===== SESSION DURATION =====
  max_session_duration = var.max_session_duration # Maximum session length (seconds)

  # ===== PERMISSIONS BOUNDARY =====
  permissions_boundary = var.permissions_boundary_arn # Hard limit on permissions

  tags = merge(
    var.tags,
    {
      Name        = "${local.name_prefix}role"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# ============================================================================
# AWS MANAGED POLICIES - Pre-Built Permission Sets
# ============================================================================
# AWS Managed Policies are pre-written, maintained by AWS, and cover common use cases.

# ===== SSM MANAGED INSTANCE CORE (Session Manager) =====
resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.enable_ssm ? 1 : 0 # Attach only if enabled

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  # Policy: AmazonSSMManagedInstanceCore
  # Grants permissions for:
  # - AWS Systems Manager (SSM) Session Manager: Browser-based shell access
  # - SSM Run Command: Execute commands remotely
  # - SSM Patch Manager: Apply OS patches
  # - SSM State Manager: Maintain instance configuration
}

# ===== CLOUDWATCH AGENT SERVER POLICY =====
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.enable_cloudwatch ? 1 : 0 # Attach only if enabled

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  # Policy: CloudWatchAgentServerPolicy
  # Grants permissions for:
  # - CloudWatch Logs: Send application/system logs
  # - CloudWatch Metrics: Send custom metrics (disk usage, memory, etc.)
  # - CloudWatch Logs CreateLogGroup/CreateLogStream
  # - CloudWatch Logs PutLogEvents
}

# ===== ADDITIONAL MANAGED POLICIES =====
# Attach any additional AWS-managed policies provided by caller
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns) # Convert list to set for for_each

  role       = aws_iam_role.this.name
  policy_arn = each.value # AWS managed policy ARN
}

# ============================================================================
# CUSTOM INLINE POLICIES - Organization-Specific Permissions
# ============================================================================
# Custom policies for permissions not covered by AWS managed policies.

resource "aws_iam_role_policy" "custom_policies" {
  for_each = var.custom_policies # Map of policy_name -> policy_json

  name   = each.key # Policy name
  role   = aws_iam_role.this.id
  policy = each.value # Policy JSON document
}

# ============================================================================
# INSTANCE PROFILE - Attach Role to EC2 Instances
# ============================================================================
# Instance Profile is a container for IAM role that EC2 instances use.

resource "aws_iam_instance_profile" "this" {
  name_prefix = local.name_prefix
  role        = aws_iam_role.this.name # Link to IAM role

  # Instance Profile explained:
  # - EC2 instances cannot directly assume IAM roles
  # - Instance Profile acts as a wrapper/container
  # - One Instance Profile = One IAM Role (1:1 relationship)
  # - Specified in Launch Template or EC2 instance configuration

  tags = merge(
    var.tags,
    {
      Name        = "${local.name_prefix}instance-profile"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
