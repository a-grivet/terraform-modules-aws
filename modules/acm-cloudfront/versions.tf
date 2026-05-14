# ============================================================================
# TERRAFORM AND PROVIDER VERSIONS - versions.tf
# ============================================================================
# This file specifies version requirements for Terraform and AWS provider.
# ============================================================================

terraform {
  required_version = ">= 1.7.4"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws.us_east_1]
    }
  }
}
