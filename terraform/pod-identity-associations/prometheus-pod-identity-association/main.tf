# ============================================================
# Prometheus Grafana Cloud Secret Read Policy
# ============================================================

resource "aws_iam_policy" "prometheus_grafana_cloud_secret_read" {
  name = "${data.terraform_remote_state.eks.outputs.eks_cluster_name}-prometheus-grafana-cloud-secret-read"

  description = "Allows Prometheus to read its Grafana Cloud token from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadPrometheusGrafanaCloudToken"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = data.aws_secretsmanager_secret.prometheus_grafana_cloud_token.arn
      },
      {
        Sid    = "DecryptPrometheusGrafanaCloudToken"
        Effect = "Allow"

        Action = [
          "kms:Decrypt"
        ]

        Resource = data.terraform_remote_state.monitoring_kms.outputs.kms_key_arn
      }
    ]
  })

  tags = var.tags
}


# ============================================================
# Prometheus EKS Pod Identity
# ============================================================

module "prometheus_pod_identity" {
  source = "../modules"

  cluster_name     = data.terraform_remote_state.eks.outputs.eks_cluster_name
  environment_name = var.environment_name

  create_namespace       = false
  create_service_account = false

  managed_policy_arn = aws_iam_policy.prometheus_grafana_cloud_secret_read.arn

  trust_policy_json = file(
    "${path.module}/../../iam-policy-json-files/pod-identity-trust-policy.json"
  )

  pod_identities = {
    prometheus = {
      namespace            = "monitoring"
      service_account_name = "prometheus-sa"
    }
  }

  tags = var.tags
}
