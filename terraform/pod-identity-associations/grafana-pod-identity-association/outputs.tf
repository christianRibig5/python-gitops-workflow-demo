output "grafana_secret_arn" {
  description = "ARN of the Grafana admin password secret"
  value       = data.aws_secretsmanager_secret.grafana_admin_password.arn
}

output "grafana_secret_read_policy_arn" {
  description = "ARN of Grafana's least-privilege secret read policy"
  value       = aws_iam_policy.grafana_secret_read.arn
}

output "grafana_service_account" {
  description = "Kubernetes service account associated with Grafana Pod Identity"
  value       = "grafana-sa"
}

output "grafana_namespace" {
  description = "Namespace of the Grafana Pod Identity association"
  value       = "monitoring"
}
