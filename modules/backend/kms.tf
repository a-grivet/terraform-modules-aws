# ============================================================================
# BACKEND MODULE - kms.tf
# ============================================================================
# This file creates the KMS key used to encrypt Terraform state files at rest.
# ============================================================================

resource "aws_kms_key" "terraform_state" {
  description         = "KMS key for Terraform state encryption"
  enable_key_rotation = true
}

# Friendly alias for the backend KMS key.
resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${var.prefix}-terraform-state-kms"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# Attach the key policy defined in data.tf.
resource "aws_kms_key_policy" "terraform_state" {
  key_id = aws_kms_key.terraform_state.id
  policy = data.aws_iam_policy_document.state_kms.json
}
