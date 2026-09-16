data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-ca-central-1-mr67svo6"
    key    = "eks/dev/terraform.tfstate"
    region = "ca-central-1"
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

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

provider "kubernetes" {
  host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data
  )

  token = data.aws_eks_cluster_auth.eks.token
}
