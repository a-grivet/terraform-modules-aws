# ============================================================================
# ECS MODULE - locals.tf
# ============================================================================
# Centralise la logique de nommage conforme à la convention Your Organization.
# Pattern : <prefix>-[np]-<app_id>-<env>-[label]
# Référence : https://
# ============================================================================

locals {
  np_segment   = var.environment == "p" ? "" : "np-"
  base         = "${local.np_segment}${var.app_id}-${var.environment}"
  label_suffix = var.label != null ? "-${var.label}" : ""

  cluster_name    = "ecs-${local.base}${local.label_suffix}"
  service_name    = "ecs-${local.base}-svc${local.label_suffix}"
  iam_exec_prefix = "org-rol-${local.base}-ecs-exec${local.label_suffix}-"
  iam_task_prefix = "org-rol-${local.base}-ecs-task${local.label_suffix}-"
}
