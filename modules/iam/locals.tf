# ============================================================================
# IAM MODULE - locals.tf
# ============================================================================
# Centralise la logique de nommage conforme à la convention Your Organization.
# Pattern : <prefix>-[np]-<app_id>-<env>-[label]
# Référence : https://
# ============================================================================

locals {
  np_segment   = var.environment == "p" ? "" : "np-"
  base         = "${local.np_segment}${var.app_id}-${var.environment}"
  label_suffix = var.label != null ? "-${var.label}" : ""
  name_prefix  = "org-rol-${local.base}${local.label_suffix}-"
}
