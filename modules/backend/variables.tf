# ============================================================================
# BACKEND MODULE VARIABLES - variables.tf
# ============================================================================
# The backend infrastructure needs only a naming prefix and a region.
# The locking mechanism is provided natively by the S3 backend via use_lockfile.
# ============================================================================

variable "region" {
  description = "AWS region where backend resources are created"
  type        = string
}

variable "prefix" {
  description = "Prefix used for naming backend resources such as the S3 bucket and KMS key"
  type        = string
}
