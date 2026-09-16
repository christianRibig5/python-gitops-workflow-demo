output "grafana_admin_secret_arn" {
  description = "ARN of the Grafana admin password secret"
  value       = aws_secretsmanager_secret.grafana_admin_password.arn
}

output "grafana_admin_secret_name" {
  description = "Name of the Grafana admin password secret"
  value       = aws_secretsmanager_secret.grafana_admin_password.name
}
