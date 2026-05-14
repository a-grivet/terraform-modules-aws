# ============================================================================
# TERRAFORM AND PROVIDER VERSIONS - versions.tf
# ============================================================================
# This file defines the minimum Terraform and AWS provider versions required
# by this module.
# ============================================================================

terraform {
  required_version = ">= 1.7.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Official AWS provider from HashiCorp
      version = ">= 5.0"        # Minimum AWS provider version
    }
  }
}
