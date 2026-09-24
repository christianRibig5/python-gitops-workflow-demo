# ============================================================
# Alertmanager Zoho SMTP Secret
#
# Terraform manages:
# - The AWS Secrets Manager secret container
# - Customer-managed KMS encryption for the secret
#
# The actual Zoho SMTP app password is added separately using
# the secure AWS CLI script so that the secret value is not
# stored in Terraform state.
#
# The KMS key is managed by the monitoring-kms Terraform
# component and consumed here through Terraform remote state.
# ============================================================


# ------------------------------------------------------------
# Monitoring KMS Remote State
# ------------------------------------------------------------

# Read the customer-managed KMS key created by the
# monitoring-kms Terraform component.
data "terraform_remote_state" "monitoring_kms" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-ca-central-1-i1zfl3al"
    key    = "kms/monitoring/dev/terraform.tfstate"
    region = "ca-central-1"
  }
}


# ------------------------------------------------------------
# Secret Naming
# ------------------------------------------------------------

locals {
  alertmanager_zoho_secret_name = "${var.environment_name}/monitoring/alertmanager/zoho-smtp-password"
}


# ------------------------------------------------------------
# AWS Secrets Manager Secret
# ------------------------------------------------------------

resource "aws_secretsmanager_secret" "alertmanager_zoho_smtp" {
  name = local.alertmanager_zoho_secret_name

  description = "Zoho SMTP app password used by Alertmanager in the ${var.environment_name} environment"

  # Encrypt the secret using the project's customer-managed KMS key.
  kms_key_id = data.terraform_remote_state.monitoring_kms.outputs.kms_key_arn

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name        = local.alertmanager_zoho_secret_name
      Environment = var.environment_name
      Purpose     = "Alertmanager email notifications through Zoho SMTP"
    }
  )
}
