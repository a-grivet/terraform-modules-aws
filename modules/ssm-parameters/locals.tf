# ============================================================================
# SSM PARAMETERS MODULE - locals.tf
# ============================================================================
# Centralizes naming logic following the organization naming convention.
# Pattern : <prefix>-[np]-<app_id>-<env>-[label]
# Reference: https://
#
# Note: SSM Parameters use a hierarchical path format. The np segment is
# included as a dedicated path level between app_id and env:
#   Non-prod : /{app_id}/np/{env}/database/...
#   Prod     : /{app_id}/{env}/database/...
# ============================================================================

locals {
  # np path segment: present only for non-production environments
  np_segment = var.environment == "p" ? "" : "np/"

  # SSM path prefix — incorporates app_id, np (if non-prod) and env following
  # the Your Organization convention adapted to the SSM Parameter Store path format.
  path_prefix = var.parameter_path_prefix != null ? var.parameter_path_prefix : "/${var.app_id}/${local.np_segment}${var.environment}/database"
  # Examples:
  #   dev  → /myappid/np/d/database/writer-endpoint
  #   prod → /myappid/p/database/writer-endpoint

  common_tags = merge(
    var.tags,
    {
      Module    = "ssm-parameters"
      ManagedBy = "Terraform"
    }
  )
}
