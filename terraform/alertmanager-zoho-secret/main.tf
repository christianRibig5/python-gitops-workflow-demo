# ============================================================
# AWS Secrets Manager secret for Alertmanager Zoho SMTP
#
# Terraform creates the secret container only.
# The actual Zoho app password is added separately through
# the AWS CLI so that it is not stored in Terraform state.
# ============================================================

locals {
  alertmanager_zoho_secret_name = "${var.environment_name}/monitoring/alertmanager/zoho-smtp-password"
}

resource "aws_secretsmanager_secret" "alertmanager_zoho_smtp" {
  name = local.alertmanager_zoho_secret_name

  description = "Zoho SMTP app password used by Alertmanager in the ${var.environment_name} environment"

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name    = local.alertmanager_zoho_secret_name
      Purpose = "Alertmanager email notifications through Zoho SMTP"
    }
  )
}
