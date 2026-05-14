# ============================================================================
# ELASTICACHE REDIS MODULE - versions.tf
# ============================================================================
# This module relies only on the AWS provider and follows the same Terraform
# and provider baseline as the rest of the centralized module set.
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
