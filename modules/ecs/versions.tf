# ============================================================================
# ECS MODULE - versions.tf
# ============================================================================

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Official AWS provider from HashiCorp
      version = ">= 5.0"        # Minimum AWS provider version
    }
  }
}
