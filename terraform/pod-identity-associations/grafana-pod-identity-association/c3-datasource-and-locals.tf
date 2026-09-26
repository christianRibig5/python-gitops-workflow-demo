# ============================================================
# EKS Remote State
# ============================================================

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-ca-central-1-i1zfl3al"
    key    = "eks/dev/terraform.tfstate"
    region = "ca-central-1"
  }
}


# ============================================================
# Monitoring KMS Remote State
# ============================================================
# Provides the KMS key ARN used to encrypt monitoring secrets.
# The IAM policy in main.tf uses this output for kms:Decrypt.
# ============================================================

data "terraform_remote_state" "monitoring_kms" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-ca-central-1-i1zfl3al"
    key    = "kms/monitoring/dev/terraform.tfstate"
    region = "ca-central-1"
  }
}


# ============================================================
# EKS Authentication
# ============================================================

data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}


# ============================================================
# Grafana Secret
# ============================================================

locals {
  grafana_secret_name = (
    var.grafana_secret_name != null
    ? var.grafana_secret_name
    : "${var.environment_name}/monitoring/grafana/admin-password"
  )
}

data "aws_secretsmanager_secret" "grafana_admin_password" {
  name = local.grafana_secret_name
}


# ============================================================
# Kubernetes Provider
# ============================================================

provider "kubernetes" {
  host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data
  )

  token = data.aws_eks_cluster_auth.eks.token
}
