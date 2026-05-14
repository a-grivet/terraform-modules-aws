# ============================================================================
# IAM MODULE OUTPUTS - outputs.tf
# ============================================================================
# This file defines output values for the IAM role and instance profile.
# Outputs provide identifiers needed by other modules (ASG, EC2) to attach
# the IAM role to instances.
#
# Key outputs:
# - Role identifiers (ARN, name, ID) for policy attachments
# - Instance profile name (CRITICAL for EC2/ASG configuration)
# - Unique IDs for tracking and auditing
# ============================================================================

# ============================================================================
# IAM ROLE OUTPUTS
# ============================================================================
# Information about the IAM role (trust policy + permissions)

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
  # Amazon Resource Name (full identifier)
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
  # Human-readable role name
}

output "role_id" {
  description = "ID of the IAM role"
  value       = aws_iam_role.this.id
  # Role identifier (same as role_name for IAM roles)
}

output "role_unique_id" {
  description = "Unique ID of the IAM role"
  value       = aws_iam_role.this.unique_id
  # Stable unique identifier for the role
}

# ============================================================================
# INSTANCE PROFILE OUTPUTS
# ============================================================================
# Information about the instance profile (container for IAM role)

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.this.arn
  # Amazon Resource Name for the instance profile
}

output "instance_profile_name" {
  description = "Name of the instance profile (use this for EC2/ASG)"
  value       = aws_iam_instance_profile.this.name
  # **MOST IMPORTANT OUTPUT** - Use this in EC2/ASG configuration
  #
  # How to use in ASG module:
  #
  # module "asg" {
  #   source = "./modules/asg"
  #
  #   iam_instance_profile_name = module.iam.instance_profile_name  # <- HERE
  #
  #   # ... other configuration
  # }
  #
  # How to use in EC2 launch template:
  #
  # resource "aws_launch_template" "app" {
  #   iam_instance_profile {
  #     name = module.iam.instance_profile_name  # <- HERE
  #   }
  # }
}

output "instance_profile_id" {
  description = "ID of the instance profile"
  value       = aws_iam_instance_profile.this.id
  # Instance profile identifier (same as instance_profile_name)
}

output "instance_profile_unique_id" {
  description = "Unique ID of the instance profile"
  value       = aws_iam_instance_profile.this.unique_id
  # Stable unique identifier for the instance profile
}
