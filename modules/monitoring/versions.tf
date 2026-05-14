# ============================================================================
# TERRAFORM AND PROVIDER VERSIONS - versions.tf
# ============================================================================
# This file specifies version requirements for Terraform and the AWS provider.
# These constraints keep the shared monitoring module aligned with the rest
# of the centralized catalog.
# ============================================================================

terraform {
  # Minimum Terraform version required to use this module
  required_version = ">= 1.7.4"

  # Required provider configurations
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Official AWS provider from HashiCorp
      version = ">= 5.0"        # Minimum AWS provider version
    }
  }
}
