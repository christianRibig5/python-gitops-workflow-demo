resource "aws_iam_policy" "grafana_secret_read" {
  name = "${data.terraform_remote_state.eks.outputs.eks_cluster_name}-grafana-admin-secret-read"

  description = "Allows Grafana to read its admin password from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadGrafanaAdminPassword"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = data.aws_secretsmanager_secret.grafana_admin_password.arn
      }
    ]
  })

  tags = merge(var.tags, { Environment = var.environment_name })
}

module "grafana_pod_identity" {
  source = "../modules"

  cluster_name     = data.terraform_remote_state.eks.outputs.eks_cluster_name
  environment_name = var.environment_name

  create_namespace       = false
  create_service_account = false

  managed_policy_arn = aws_iam_policy.grafana_secret_read.arn

  trust_policy_json = file(
    "${path.module}/../../iam-policy-json-files/pod-identity-trust-policy.json"
  )

  pod_identities = {
    grafana = {
      namespace            = "monitoring"
      service_account_name = "grafana-sa"
    }
  }

  tags = merge(var.tags, { Environment = var.environment_name })
}
