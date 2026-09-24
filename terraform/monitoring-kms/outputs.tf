# ============================================================
# Monitoring KMS Outputs
# ============================================================

output "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt monitoring secrets"
  value       = aws_kms_key.monitoring_secrets.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used to encrypt monitoring secrets"
  value       = aws_kms_key.monitoring_secrets.key_id
}

output "kms_alias_name" {
  description = "Alias of the KMS key used to encrypt monitoring secrets"
  value       = aws_kms_alias.monitoring_secrets.name
}
