# ============================================================
# KMS key for monitoring secrets
#
# This customer-managed KMS key encrypts Secrets Manager
# secrets used by the monitoring stack, including:
# - Grafana admin password
# - Alertmanager Zoho SMTP password
# ============================================================

resource "aws_kms_key" "monitoring_secrets" {
  description = "KMS key for monitoring Secrets Manager secrets in the ${var.environment_name} environment"

  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment_name}-monitoring-secrets-kms"
      Environment = var.environment_name
      Purpose     = "Encrypt monitoring secrets"
    }
  )
}

# Human-readable alias for the KMS key
resource "aws_kms_alias" "monitoring_secrets" {
  name          = "alias/${var.environment_name}-monitoring-secrets"
  target_key_id = aws_kms_key.monitoring_secrets.key_id
}
