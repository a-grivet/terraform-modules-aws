# ============================================================================
# TERRAFORM AND PROVIDER VERSIONS - versions.tf
# ============================================================================
# This file specifies version requirements for Terraform and AWS provider.
# Version constraints ensure compatibility and prevent breaking changes.
# 
# Why this matters:
# - Ensures everyone uses compatible Terraform/provider versions
# - Prevents unexpected behavior from version differences
# - Documents the minimum versions tested with this module
# ============================================================================

terraform {
  # Minimum Terraform version required to use this module
  required_version = ">= 1.7.4"
  # Minimum Terraform version required to run this configuration

  # Required provider configurations
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Official AWS provider from HashiCorp
      version = ">= 5.0"        # Minimum AWS provider version
      # ">= 5.0" means: AWS provider version 5.0 or newer
    }
  }
}
