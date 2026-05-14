terraform {
  required_version = ">= 1.7.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ============================================================================
# ACM-CLOUDFRONT VALIDATION EXAMPLE - main.tf
# ============================================================================
# This example validates the acm-cloudfront module through a minimal root
# module used by CI.
# The shared module requires an aliased provider in us-east-1, so validating
# the module directory alone is not sufficient.
# This example wires the expected providers explicitly to mirror the real
# consumer pattern.
# ============================================================================

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "acm_cloudfront" {
  source = "../../modules/acm-cloudfront"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  app_id                    = "validation"
  environment               = "d"
  domain_name               = "example.com"
  subject_alternative_names = ["www.example.com"]
  zone_id                   = "Z1234567890EXAMPLE"
  tags                      = {}
}
