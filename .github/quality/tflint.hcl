# ============================================================================
# TFLINT CONFIGURATION - .tflint.hcl
# ============================================================================
# This file configures TFLint for the shared terraform-modules repository.
#
# Why this matters:
# - Keeps linting behavior consistent across all modules
# - Catches Terraform anti-patterns early in CI
# - Prepares the repository for future rule extensions without changing workflows
# ============================================================================

config {
  # Return non-zero exit code when issues are found.
  # This makes CI fail fast when a module violates lint rules.
  force = false

  # Do not attempt to inspect variables from the environment automatically.
  # Shared modules should remain deterministic during CI validation.
  disabled_by_default = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.37.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
