# ============================================================================
# LOGS MODULE - locals.tf
# ============================================================================
# Centralise la logique de nommage conforme à la convention Your Organization.
#
# Pattern : <prefix>-[np]-<app_id>-<env>-[label]
#   1. prefix      : type de ressource — défini ici, transparent pour l'utilisateur
#   2. np          : ajouté automatiquement pour tous les environnements non-prod (env != "p")
#   3. app_id      : identifiant applicatif Your Organization (var.app_id)
#   4. env         : code environnement Your Organization (var.environment)
#   5. label       : suffixe optionnel pour distinguer plusieurs instances (var.label)
#
# Référence : https://
# ============================================================================

locals {
  # Segment np : présent uniquement hors production
  np_segment = var.environment == "p" ? "" : "np-"

  # Base commune : [np-]<app_id>-<env>
  base = "${local.np_segment}${var.app_id}-${var.environment}"

  # Suffixe label optionnel
  label_suffix = var.label != null ? "-${var.label}" : ""

  # Nom du bucket S3 : suffixé par l'account ID pour garantir l'unicité globale
  bucket_name = "s3-${local.base}-logs${local.label_suffix}-${data.aws_caller_identity.current.account_id}"

  # Nom pour le tag Name (sans account ID)
  tag_name = "s3-${local.base}-logs${local.label_suffix}"
}
