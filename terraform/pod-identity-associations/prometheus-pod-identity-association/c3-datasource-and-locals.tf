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
# Grafana Cloud Secret
# ============================================================

locals {
  prometheus_grafana_cloud_secret_name = (
    var.prometheus_grafana_cloud_secret_name != null
    ? var.prometheus_grafana_cloud_secret_name
    : "${var.environment_name}/monitoring/prometheus/grafana-cloud-token"
  )
}

data "aws_secretsmanager_secret" "prometheus_grafana_cloud_token" {
  name = local.prometheus_grafana_cloud_secret_name
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
