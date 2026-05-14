# ============================================================================
# TERRAFORM AND PROVIDER VERSIONS - versions.tf
# ============================================================================
# Version constraints keep this module aligned with the Terraform and AWS
# provider versions already used across the centralized modules.
# ============================================================================

terraform {
  required_version = ">= 1.7.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Official AWS provider from HashiCorp
      version = ">= 5.0"        # Minimum AWS provider version
    }
    null = {
      source  = "hashicorp/null" # Official Null provider from HashiCorp
      version = ">= 3.0"         # Required for documented KMS grant placeholder resources
    }
  }
}
