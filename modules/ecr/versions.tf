# ============================================================================
# ECR MODULE - versions.tf
# ============================================================================
# Version constraints are aligned with the rest of the centralized module set
# to keep provider behavior consistent across repositories.
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
