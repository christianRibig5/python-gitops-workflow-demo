# ============================================================
# Alertmanager read-only AWS Secrets Manager policy
# ============================================================

resource "aws_iam_policy" "alertmanager_secret_read" {
  name = "${data.terraform_remote_state.eks.outputs.eks_cluster_name}-alertmanager-secret-read"

  description = "Allows Alertmanager to read only its Zoho SMTP password"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadAlertmanagerZohoPassword"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = data.aws_secretsmanager_secret.alertmanager_zoho.arn
      }
    ]
  })

  tags = var.tags
}

# ============================================================
# Alertmanager EKS Pod Identity
# ============================================================

module "alertmanager_pod_identity" {
  source = "../modules"

  cluster_name     = data.terraform_remote_state.eks.outputs.eks_cluster_name
  environment_name = var.environment_name

  create_namespace       = false
  create_service_account = false

  managed_policy_arn = aws_iam_policy.alertmanager_secret_read.arn

  trust_policy_json = file(
    "${path.module}/../../iam-policy-json-files/pod-identity-trust-policy.json"
  )

  pod_identities = {
    alertmanager = {
      namespace            = "monitoring"
      service_account_name = "alertmanager-sa"
    }
  }

  tags = var.tags
}
