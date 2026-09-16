# Terraform creates the Grafana admin-password secret container only.
# Add the password separately through your secure AWS CLI script
# so the password is not stored in Terraform state.

locals {
  grafana_admin_secret_name = "${var.environment_name}/monitoring/grafana/admin-password"
}

resource "aws_secretsmanager_secret" "grafana_admin_password" {
  name        = local.grafana_admin_secret_name
  description = "Grafana admin login password for the ${var.environment_name} environment"

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
