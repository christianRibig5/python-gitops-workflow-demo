output "prometheus_grafana_cloud_secret_arn" {
  description = "ARN of the Prometheus Grafana Cloud token secret"
  value       = aws_secretsmanager_secret.prometheus_grafana_cloud_token.arn
}

output "prometheus_grafana_cloud_secret_name" {
  description = "Name of the Prometheus Grafana Cloud token secret"
  value       = aws_secretsmanager_secret.prometheus_grafana_cloud_token.name
}
