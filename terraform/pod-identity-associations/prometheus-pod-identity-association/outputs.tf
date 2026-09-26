# ============================================================
# Prometheus Pod Identity Outputs
# ============================================================

output "prometheus_grafana_cloud_secret_read_policy_arn" {
  description = "ARN of the IAM policy allowing Prometheus to read and decrypt the Grafana Cloud token"
  value       = aws_iam_policy.prometheus_grafana_cloud_secret_read.arn
}

output "prometheus_grafana_cloud_secret_arn" {
  description = "ARN of the Grafana Cloud token secret consumed by Prometheus"
  value       = data.aws_secretsmanager_secret.prometheus_grafana_cloud_token.arn
}

output "prometheus_grafana_cloud_secret_name" {
  description = "Name of the Grafana Cloud token secret consumed by Prometheus"
  value       = data.aws_secretsmanager_secret.prometheus_grafana_cloud_token.name
}

output "eks_cluster_name" {
  description = "EKS cluster associated with Prometheus Pod Identity"
  value       = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

output "prometheus_service_account" {
  description = "Kubernetes service account used by Prometheus"
  value       = "prometheus-sa"
}

output "prometheus_namespace" {
  description = "Kubernetes namespace containing Prometheus"
  value       = "monitoring"
}
