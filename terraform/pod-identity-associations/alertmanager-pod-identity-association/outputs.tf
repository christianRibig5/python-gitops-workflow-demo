output "alertmanager_secret_arn" {
  description = "ARN of the Zoho SMTP secret accessible by Alertmanager"
  value       = data.aws_secretsmanager_secret.alertmanager_zoho.arn
}

output "alertmanager_secret_read_policy_arn" {
  description = "ARN of the Alertmanager Secrets Manager read policy"
  value       = aws_iam_policy.alertmanager_secret_read.arn
}

output "alertmanager_service_account" {
  description = "Kubernetes service account used by Alertmanager"
  value       = "alertmanager-sa"
}

output "alertmanager_namespace" {
  description = "Kubernetes namespace used by Alertmanager"
  value       = "monitoring"
}
