# ============================================================================
# DYNAMODB MODULE - locals.tf
# ============================================================================
# Centralise la logique de nommage conforme à la convention Your Organization.
# Pattern : <prefix>-[np]-<app_id>-<env>-[label]
# Référence : https://
# ============================================================================

locals {
  np_segment   = var.environment == "p" ? "" : "np-"
  base         = "${local.np_segment}${var.app_id}-${var.environment}"
  label_suffix = var.label != null ? "-${var.label}" : ""
  name_prefix  = "ddb-${local.base}${local.label_suffix}"

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "dynamodb"
    }
  )

  # Collect all attributes needed for tables: primary keys, GSIs, and LSIs.
  all_attributes = {
    for table_name, table_config in var.tables :
    table_name => distinct(concat(
      [
        { name = table_config.hash_key, type = table_config.hash_key_type }
      ],
      table_config.range_key != null ? [
        { name = table_config.range_key, type = table_config.range_key_type }
      ] : [],
      flatten([for gsi in table_config.global_secondary_indexes : [
        { name = gsi.hash_key, type = gsi.hash_key_type },
        gsi.range_key != null ? { name = gsi.range_key, type = gsi.range_key_type } : null
      ]]),
      flatten([for lsi in table_config.local_secondary_indexes : [
        { name = lsi.range_key, type = lsi.range_key_type }
      ]])
    ))
  }
}
