# Read the customer-managed KMS key created by the monitoring-kms component
data "terraform_remote_state" "monitoring_kms" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-ca-central-1-i1zfl3al"
    key    = "kms/monitoring/dev/terraform.tfstate"
    region = "ca-central-1"
  }
}

# Terraform creates the Grafana admin-password secret container only.
# Add the password separately through your secure AWS CLI script
# so the password is not stored in Terraform state.

locals {
  grafana_admin_secret_name = "${var.environment_name}/monitoring/grafana/admin-password"
}

resource "aws_secretsmanager_secret" "grafana_admin_password" {
  name        = local.grafana_admin_secret_name
  description = "Grafana admin login password for the ${var.environment_name} environment"

  kms_key_id = data.terraform_remote_state.monitoring_kms.outputs.kms_key_arn

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Environment = var.environment_name
      Name        = local.grafana_admin_secret_name
      Purpose     = "Grafana admin dashboard login"
    }
  )
}
