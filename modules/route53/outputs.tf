# ============================================================================
# ROUTE53 MODULE OUTPUTS - outputs.tf
# ============================================================================
# Outputs expose the fully qualified domain name published by the module.
# ============================================================================

output "fqdn" {
  description = "Fully qualified domain name"
  value       = aws_route53_record.website.fqdn
}
