# ============================================================
# Prometheus Grafana Cloud Secret
#
# Terraform manages:
# - The AWS Secrets Manager secret container
# - Customer-managed KMS encryption for the secret
#
# The actual Grafana Cloud access token is added separately
# through the secure monitoring bootstrap script so that the
# sensitive value is never stored in Terraform state.
#
# The KMS key is managed by the monitoring-kms Terraform
# component and consumed here through Terraform remote state.
# ============================================================


# ------------------------------------------------------------
# Monitoring KMS Remote State
# ------------------------------------------------------------

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
  prometheus_grafana_cloud_secret_name = "${var.environment_name}/monitoring/prometheus/grafana-cloud-token"
}


# ------------------------------------------------------------
# AWS Secrets Manager Secret
# ------------------------------------------------------------

resource "aws_secretsmanager_secret" "prometheus_grafana_cloud_token" {
  name = local.prometheus_grafana_cloud_secret_name

  description = "Grafana Cloud access token used by Prometheus remote_write in the ${var.environment_name} environment"

  # Encrypt with the monitoring customer-managed KMS key.
  kms_key_id = data.terraform_remote_state.monitoring_kms.outputs.kms_key_arn

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name        = local.prometheus_grafana_cloud_secret_name
      Environment = var.environment_name
      Purpose     = "Prometheus remote_write authentication to Grafana Cloud"
    }
  )
}
